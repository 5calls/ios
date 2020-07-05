//
//  Analytics.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation

// An interface to arbitrary analytics backends
protocol Analytics {
    
    // Initialize the analytics system. Implementers should guard against initializing more than once.
    func start()
    
    func trackEvent(_ name: String)
    func trackEvent(_ name: String, properties: [String: String])
    func trackError(error: Error)
}
