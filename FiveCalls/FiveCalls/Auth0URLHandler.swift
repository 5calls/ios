//
//  Auth0URLHandler.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/15/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import Auth0

class Auth0URLHandler: AppURLHandler {
    func canHandle(url: URL) -> Bool {
        url.host == "5callsos.auth0.com"
    }
    
    func handle(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        Auth0.resumeAuth(url, options: options)
    }
}
