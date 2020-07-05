//
//  ContactLogsLoader.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation

protocol ContactLogsAccess {
    static func load() -> ContactLogs
    static func clear()
}

/// Responsible for loading contact logs from persistent storage.
struct ContactLogsLoader: ContactLogsAccess {
    
    static let fileName = "ContactLogs"
    
    private static var sharedAppGroupFileURL: URL {
        let appGroupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Configuration.appGroupIdentifier)!
        return appGroupContainer.appendingPathComponent(fileName)
    }
    
    private static var store: ContactLogsStore {
        FileContactLogsStore(url: sharedAppGroupFileURL, analytics: Current.analytics)
    }
    
    static func load() -> ContactLogs {
        migrateIfNeeded()
        return store.load()
    }
    
    static func clear() {
        store.removeData()
    }
    
    /// Migrate storage from the old location to the shared App Group container
    private static func migrateIfNeeded() {
        let appSupport = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)
        let pantryDir = appSupport.appendingPathComponent("com.thatthinginswift.pantry")
        let oldLocation = pantryDir.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: oldLocation.path) {
            print("Migrating contact logs storage from old location to the shared App Group container...")
            let newLocation = sharedAppGroupFileURL
            try! FileManager.default.moveItem(at: oldLocation, to: newLocation)
            try! FileManager.default.removeItem(at: pantryDir)
        }
    }
}
