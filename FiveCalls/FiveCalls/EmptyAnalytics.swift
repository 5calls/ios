//
//  EmptyAnalytics.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

struct EmptyAnalytics: Analytics {
    func start() {
    }
    
    func trackEvent(_ name: String) {
    }
    
    func trackEvent(_ name: String, properties: [String : String]) {
    }
    
    func trackError(error: Error) {
    }
}
