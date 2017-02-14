//
//  functions.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/13/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

func isUITesting() -> Bool {
    return ProcessInfo.processInfo.environment["UI_TESTING"] == "1"
}
    
