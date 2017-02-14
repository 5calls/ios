//
//  URLSessionProvider.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/13/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct URLSessionProvider {
    static func buildSession(configuration: URLSessionConfiguration) -> URLSession {
        if isUITesting() {
            return SeededURLSession()
        } else {
            return URLSession(configuration: configuration)
        }
    }
}
