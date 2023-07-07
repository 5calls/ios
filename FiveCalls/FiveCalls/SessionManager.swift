//
//  SessionManager.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 9/24/21.
//  Copyright © 2021 5calls. All rights reserved.
//

import Foundation
import FirebaseAuth

class SessionManager {
    static let shared = SessionManager()
    var idToken: String?
    var userID: String?

    // startSession is only called on app startup, so it's possible that some time in the future
    // this ID token will be expired but considering our short total app session times, probably unlikely.
    // Will monitor the server for expired tokens and adjust if needed
    func startSession() {
        Auth.auth().signInAnonymously { result, error in
            self.userID = result?.user.uid
            let cid = UserDefaults.standard.string(forKey: UserDefaultsKey.callerID.rawValue)
            if cid == nil || cid == "" {
                UserDefaults.standard.set(self.userID, forKey: UserDefaultsKey.callerID.rawValue)
            }
            
            result?.user.getIDToken { token, tokenError in
                self.idToken = token
            }
        }
    }

    func refreshToken(completion: @escaping () -> Void) {
        Auth.auth().signInAnonymously { result, error in
            result?.user.getIDTokenForcingRefresh(true) { token, tokenError in
                self.idToken = token
                completion()
            }
        }
    }
}
