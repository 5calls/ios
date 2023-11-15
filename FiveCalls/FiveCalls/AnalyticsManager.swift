//
//  AnalyticsManager.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 5/29/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation
import PlausibleSwift

class AnalyticsManager {
    static let shared = AnalyticsManager()
    private var plausible: PlausibleSwift?
    
    private init() {
        plausible = try? PlausibleSwift(domain: "5calls.org")
    }
        
    var callerID: String {
        if let cid = UserDefaults.standard.string(forKey: UserDefaultsKey.callerID.rawValue) {
            return cid
        }
        
        let cid = UUID()
        UserDefaults.standard.setValue(cid.uuidString, forKey: UserDefaultsKey.callerID.rawValue)
        return cid.uuidString
    }
    
    func trackPageview(path: String, properties: [String: String] = .init()) {
        #if !DEBUG
        let alwaysUseProperties: [String: String] = ["isIOSApp": "true"]
        try? plausible?.trackPageview(path: path, properties: properties.merging(alwaysUseProperties) { _, new in new })
        #endif
    }
    
    func trackEvent(name: String, path: String, properties: [String: String] = .init()) {
        #if !DEBUG
        let alwaysUseProperties: [String: String] = ["isIOSApp": "true"]
        try? plausible?.trackEvent(event: name, path: path, properties: properties.merging(alwaysUseProperties) { _, new in new })
        #endif
    }
    
    // not quite ready to remove all the references to this, but I don't want to push these all to plausible immediately
    func trackEventOld(withName name: String, andProperties properties: [String: String] = [:]) {
        #if !DEBUG
        // firebase does not support colons in event names...
//        let sanitizedEventName = name.replacingOccurrences(of: ":", with: "_").replacingOccurrences(of: " ", with: "")
//        Analytics.logEvent(sanitizedEventName, parameters: properties)
        #endif
    }
    
    func trackError(error: Error) {
        // no remote error tracking right now
    }
}
