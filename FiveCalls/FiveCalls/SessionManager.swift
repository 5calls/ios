//
//  SessionManager.swift
//  FiveCalls
//
//  Created by Melville Stanley on 12/27/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Auth0
import PromiseKit

extension Notification.Name {
    static let userProfileChanged = Notification.Name("userProfileChanged")
}

public enum SessionManagerError : Error {
    case failedWrite
    case invalidStatus
    case noAccessToken
    case notLoggedIn
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
        firstly {
            self.authenticate()
        }.then { credentials -> Promise<UserInfo> in
            guard self.credentialsManager.store(credentials: credentials) else {
                print("Error writing the user's credentials")
                return Promise(error: SessionManagerError.failedWrite)
            }
            return self.fetchUserProfile(credentials)
        }.then { userInfo -> Promise<Bool> in
            self.userProfile = userInfo
            return self.sendUnreportedStats()
        }.done { _ in
            NotificationCenter.default.post(Notification(name: .userProfileChanged))
        }.catch { error in
            print("Failed to start a user session: \(error)")
            // this is likely the user cancelling the flow, not a critical error
            // and tracking the error in crashlytics here causes a crash 😕
        }
    }
    
    func refreshToken() -> Promise<Credentials> {
        return firstly {
            self.authenticate()
        }.then { credentials -> Promise<Credentials> in
            guard self.credentialsManager.store(credentials: credentials) else {
                print("Error writing the user's credentials")
                return Promise(error: SessionManagerError.failedWrite)
            }
            return Promise { seal in seal.fulfill(credentials) }
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

    private func authenticate() -> Promise<Credentials> {
        return Promise { seal in
            guard credentialsManager.hasValid() else {
                // No valid credentials exist, present the hosted login page
                Auth0
                    .webAuth()
                    .audience("https://5callsos.auth0.com/userinfo")
                    .scope("openid profile offline_access")
                    .start { result in
                        switch result {
                        case .success(let credentials):
                            seal.fulfill(credentials)
                        case .failure(let error):
                            AnalyticsManager.shared.trackError(error: error)
                            print("User login failed with error: \(error)")
                            seal.reject(error)
                        }
                }
                return
            }
            // Most of the time we'll already have some credentials to work with.
            // If our existing credentials are expired or otherwise invalid this
            // call will handle refreshing them
            credentialsManager.credentials(callback: seal.resolve)
        }
    }
    
    
    private func fetchUserProfile(_ credentials: Credentials) -> Promise<UserInfo> {
        return Promise { seal in
            if let accessToken = credentials.accessToken {
                Auth0
                    .authentication()
                    .userInfo(withAccessToken: accessToken)
                    .start { result in
                        switch(result) {
                        case .success(let profile):
                            self.userProfile = profile
                            seal.fulfill(profile)
                        case .failure(let error):
                            print("Error fetching user profile: \(error)")
                            seal.reject(error)
                        }
                }
            } else {
                seal.reject(SessionManagerError.noAccessToken)
            }
        }
    }
    
    private func sendUnreportedStats() -> Promise<Bool> {
        guard userIsLoggedIn() else {
            return Promise.init(error: SessionManagerError.notLoggedIn)
        }
        
        let logs = ContactLogs.load()
        let unreportedLogs = logs.unreported()
        guard unreportedLogs.count > 0 else { return .value(true) }
        
        return Promise { seal in
            let logs = ContactLogs.load()
            var unreportedLogs = logs.unreported()

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
                        
                        
                        if status >= 200 && status <= 299 {
                            seal.fulfill(true)
                        } else {
                            seal.reject(reportStatsOperation.error ?? SessionManagerError.invalidStatus)
                        }
                    }
                }
                reportStatsOperation.start()
            } else {
                // This will be the case most of the time, since contacts are usually
                // reported immediately.
                seal.fulfill(true)
            }
        }
    }
}
