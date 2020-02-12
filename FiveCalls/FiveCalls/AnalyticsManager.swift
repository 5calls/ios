//
//  AnalyticsManager.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 5/29/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private var setupComplete = false
    
    private init() {}
    
    func startup() {
        if let infoPlist = Bundle.main.infoDictionary, let appCenterKey = infoPlist["AppCenterAPIKey"] as? String {
            MSAppCenter.start(appCenterKey, withServices: [
                MSAnalytics.self,
                MSCrashes.self
            ])
        } else {
            assertionFailure("No AppCenterAPIKey was found in the Info.plist")
        }

        setupComplete = true
    }
    
    func trackEvent(withName name: String, andProperties properties: [String: String] = [:]) {
        if !setupComplete { assertionFailure("tracking before we've setup analytics") }
        
        MSAnalytics.trackEvent(name, withProperties: properties)
    }
    
    func trackError(error: Error) {
        MSAnalytics.trackEvent("Error", withProperties: ["message": error.localizedDescription])
    }
}
