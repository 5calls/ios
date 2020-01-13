//
//  SessionManager.swift
//  FiveCalls
//
//  Created by Melville Stanley on 12/27/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Auth0

extension Notification.Name {
    static let userProfileChanged = Notification.Name("userProfileChanged")
}

public enum SessionManagerError : Error {
    case failedWrite
    case invalidStatus
    case noAccessToken
    case notLoggedIn
    case unknownAuth0Error
}

class SessionManager {
    
    // Set up our singleton
    static let shared = SessionManager()
    
    // The profile for the user who is currently logged in, or nil if the user isn't logged in
    var userProfile : UserInfo?

    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    
    func userHasCredentials() -> Bool {
        return credentialsManager.hasValid()
    }
    
    func userIsLoggedIn() -> Bool {
        return userProfile != nil
    }
    
    func startSession() {
        self.authenticate { (result) in
            switch result {
            case .success(let credentials):
                guard self.credentialsManager.store(credentials: credentials) else {
                    print("error writing credentials")
                    AnalyticsManager.shared.trackError(error: SessionManagerError.failedWrite)
                    return
                }
                
                self.fetchUserProfile(credentials, completion: { (result) in
                    switch result {
                    case .success(let userInfo):
                        self.userProfile = userInfo
                        self.sendUnreportedStats()
                        NotificationCenter.default.post(Notification(name: .userProfileChanged))
                    case .failure(let error):
                        print("error fetching profile: \(error)")
                        AnalyticsManager.shared.trackError(error: error)
                    }
                })
            case .failure(let error):
                print("error authenticating: \(error)")
                AnalyticsManager.shared.trackError(error: error)
            }
        }
    }
    
    func refreshToken(completion: @escaping (Swift.Result<Credentials, Error>) -> Void) {
        authenticate { (result) in
            switch result {
            case .success(let credentials):
                guard self.credentialsManager.store(credentials: credentials) else {
                    completion(.failure(SessionManagerError.failedWrite))
                    return
                }
            case .failure(let error):
                print("error with creds: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func stopSession() {
        let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        if (!credentialsManager.clear()) {
            print("Error clearing user credentials")
        }
        userProfile = nil
        NotificationCenter.default.post(Notification(name: .userProfileChanged))
    }

    private func authenticate(completion: @escaping (Swift.Result<Credentials, Error>) -> Void) {
        guard credentialsManager.hasValid() else {
            // No valid credentials exist, present the hosted login page
            Auth0
                .webAuth()
                .audience("https://5callsos.auth0.com/userinfo")
                .scope("openid profile offline_access")
                .start { result in
                    switch result {
                    case .success(let credentials):
                        completion(.success(credentials))
                    case .failure(let error):
                        AnalyticsManager.shared.trackError(error: error)
                        print("User login failed with error: \(error)")
                        completion(.failure(error))
                    }
            }
            return
        }

        credentialsManager.credentials(callback: { (error, credentials) in
            guard let credentials = credentials else {
                completion(.failure(error ?? SessionManagerError.unknownAuth0Error))
                return
            }
            
            completion(.success(credentials))
        })
    }
    
    
    private func fetchUserProfile(_ credentials: Credentials, completion: @escaping (Swift.Result<UserInfo, Error>) -> Void) {
        if let accessToken = credentials.accessToken {
            Auth0
                .authentication()
                .userInfo(withAccessToken: accessToken)
                .start { result in
                    switch(result) {
                    case .success(let profile):
                        completion(.success(profile))
                    case .failure(let error):
                        print("Error fetching user profile: \(error)")
                        completion(.failure(error))
                    }
            }
        } else {
            completion(.failure(SessionManagerError.noAccessToken))
        }
    }
    
    private func sendUnreportedStats() {
        guard userIsLoggedIn() else {
            return
        }
        
        let logs = ContactLogs.load()
        var unreportedLogs = logs.unreported()
        guard unreportedLogs.count > 0 else { return }
        
        // we kick off a check for unreported stats in a viewDidLoad so I suspect this was racing against regular stat network requests and doubling counts on the server
        // instead, don't send unreported stats until they're a few minutes old
        unreportedLogs = unreportedLogs.filter({
            $0.date < Date().addingTimeInterval(-TimeInterval(3 * 60))
        })

        if unreportedLogs.count > 0 {
            // Send all of our unreported stats to the server.
            let reportStatsOperation = ReportUserStatsOperation(logs: logs)
            reportStatsOperation.completionBlock = {
                if let status = reportStatsOperation.httpResponse?.statusCode {
                    
                    
                    if 200...299 ~= status {
                        // looks good, do nothing
                    } else {
                        print("error sending unreported stats, \(status)")
                        AnalyticsManager.shared.trackError(error: reportStatsOperation.error ?? SessionManagerError.invalidStatus)
                    }
                }
            }
            reportStatsOperation.start()
        }
    }
}
