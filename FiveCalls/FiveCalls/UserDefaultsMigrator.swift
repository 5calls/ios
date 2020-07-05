//
//  UserDefaultsMigrator.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation

struct UserDefaultsMigrator {
    
    private let hasMigratedKey = "_hasMigrated"
    
    /// Migrates user defaults from the app container to the shared App Group so they can be read from extensions.
    func migrateIfNeeded() {
        if UserDefaults.standard.bool(forKey: hasMigratedKey) == true {
            return
        }
        
        let oldDefaults = UserDefaults.standard
        let sharedDefaults = UserDefaults.fiveCalls
        
        for key in UserDefaultsKey.allCases {
            if let obj = oldDefaults.object(forKey: key.rawValue) {
                sharedDefaults.setValue(obj, forKey: key.rawValue)
            }
        }
        oldDefaults.set(true, forKey: hasMigratedKey)
    }
}
