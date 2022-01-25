//
//  AnalyticsManager.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 5/29/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private var setupComplete = false
    
    private init() {}
    
    func startup() {

        setupComplete = true
    }
    
    func trackEvent(withName name: String, andProperties properties: [String: String] = [:]) {
        if !setupComplete { assertionFailure("tracking before we've setup analytics") }

        // firebase does not support colons in event names...
        let sanitizedEventName = name.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: " ", with: "")
        Analytics.logEvent(sanitizedEventName, parameters: properties)

    }
    
    func trackError(error: Error) {
        // no remote error tracking right now
    }
}
