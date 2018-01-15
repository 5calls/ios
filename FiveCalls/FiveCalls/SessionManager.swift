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
        guard credentialsManager.hasValid() else {
            // No valid credentials exist, present the hosted login page
            Auth0
                .webAuth()
                .audience("https://5callsos.auth0.com/userinfo")
                .scope("openid profile offline_access")
                .start { result in
                    switch result {
                    case .success(let credentials):
                        if (!self.credentialsManager.store(credentials: credentials)) {
                            print("Error writing the user's credentials")
                        }
                        self.updateUserProfile()
                    case .failure(let error):
                        print("User login failed with error: \(error)")
                    }
            }
            return
        }
        updateUserProfile()
    }
    
    func stopSession() {
        let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        if (!credentialsManager.clear()) {
            print("Error clearing user credentials")
        }
        userProfile = nil
        NotificationCenter.default.post(Notification(name: .userProfileChanged))
    }

    private func updateUserProfile() {
        credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                print("Error retreiving user credentials: \(String(describing: error))")
                return
            }
            
            if let accessToken = credentials.accessToken {
                Auth0
                    .authentication()
                    .userInfo(withAccessToken: accessToken)
                    .start { result in
                        switch(result) {
                        case .success(let profile):
                            self.userProfile = profile
                            NotificationCenter.default.post(Notification(name: .userProfileChanged))
                        case .failure(let error):
                            print("Error fetching user profile: \(error)")
                        }
                }
            }
        }
    }
}
