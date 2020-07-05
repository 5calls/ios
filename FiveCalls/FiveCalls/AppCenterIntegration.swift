//
//  AppCenterAnalytics.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class AppCenterIntegration: Analytics {
    private var hasInitialized = false
    
    func start() {
        guard !hasInitialized else { return }
        if let infoPlist = Bundle.main.infoDictionary, let appCenterKey = infoPlist["AppCenterAPIKey"] as? String {
            MSAppCenter.start(appCenterKey, withServices: [
                MSAnalytics.self,
                MSCrashes.self
            ])
        } else {
            assertionFailure("No AppCenterAPIKey was found in the Info.plist")
        }

        hasInitialized = true
    }
    
    func trackEvent(_ name: String) {
        trackEvent(name, properties: [:])
    }
    
    func trackEvent(_ name: String, properties: [String: String]) {
        assert(hasInitialized, "tracking before we've setup analytics")
        
        MSAnalytics.trackEvent(name, withProperties: properties)
    }
    
    func trackError(error: Error) {
        assert(hasInitialized, "tracking before we've setup analytics")
        MSAnalytics.trackEvent("Error", withProperties: ["message": error.localizedDescription])
    }
}
