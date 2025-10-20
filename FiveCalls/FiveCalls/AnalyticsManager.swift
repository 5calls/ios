// Copyright 5calls. All rights reserved. See LICENSE for details.

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
            let alwaysUseProperties = ["isIOSApp": "true"]
            try? plausible?.trackPageview(path: path, properties: properties.merging(alwaysUseProperties) { _, new in new })
        #endif
    }

    func trackEvent(name: String, path: String, properties: [String: String] = .init()) {
        #if !DEBUG
            let alwaysUseProperties = ["isIOSApp": "true"]
            try? plausible?.trackEvent(event: name, path: path, properties: properties.merging(alwaysUseProperties) { _, new in new })
        #endif
    }

    func trackError(error _: Error) {
        // no remote error tracking right now
    }
}
