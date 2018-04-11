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
        }.then { userInfo -> Promise<Void> in
            self.userProfile = userInfo
            return self.sendUnreportedStats()
        }.done {
            NotificationCenter.default.post(Notification(name: .userProfileChanged))
        }.catch { error in
            print("Failed to start a user session: \(error)")
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
    
    private func sendUnreportedStats() -> Promise<Void> {
        return Promise { seal in
            if userIsLoggedIn() {
                let logs = ContactLogs.load()
                let unreportedLogs = logs.unreported()
                if unreportedLogs.count > 0 {
                    // Send all of our unreported stats to the server.
                    let reportStatsOperation = ReportUserStatsOperation(logs: logs)
                    reportStatsOperation.completionBlock = {
                        if let status = reportStatsOperation.httpResponse?.statusCode {
                            if status >= 200 && status <= 299 {
                                seal.fulfill(())
                            } else {
                                seal.reject(reportStatsOperation.error ?? SessionManagerError.invalidStatus)
                            }
                        }
                    }
                    reportStatsOperation.start()
                } else {
                    // This will be the case most of the time, since contacts are usually
                    // reported immediately.
                    seal.fulfill(())
                }
            } else {
                // We can only report saved stats if the user is logged in
                seal.reject(SessionManagerError.notLoggedIn)
            }
        }
    }
}
