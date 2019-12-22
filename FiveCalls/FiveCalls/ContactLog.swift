//
//  ContactLog.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/5/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct ContactLog : Hashable, Codable {
    let issueId: String
    let contactId: String
    let phone: String
    let outcome: String
    let date: Date
    let reported: Bool
}

struct LegacyPantryWrapper: Codable {
    let expires: Int
    let storage: [ContactLog]
}

struct ContactLogs {
    private static let persistenceKey = "ContactLogs"
    
    var all: [ContactLog]
    
    init() {
        all = []
    }
    
    private init(logs: [ContactLog]) {
        all = logs
    }

    mutating func add(log: ContactLog) {
        all.append(log)
        save()
        NotificationCenter.default.post(name: .callMade, object: log)
    }
        
    func methodOfContact(to contactId: String, forIssue issueId: Int64) -> String? {
        return all.filter({$0.contactId == contactId && $0.issueId == String(issueId)}).last?.outcome
    }

    func hasContacted(contactId: String, forIssue issueId: Int64) -> Bool {
        guard let method = methodOfContact(to: contactId, forIssue: issueId) else {
            return false
        }
        
        switch method {
        // contacted and vm for compatibility
        case "contact", "contacted", "voicemail", "vm":
            return true
        default:
            return false
        }        
    }
    
    func hasCompleted(issue: Int64, allContacts: [Contact]) -> Bool {
        if (allContacts.count == 0) {
            return false
        }
        for contact in allContacts {
            if !hasContacted(contactId: contact.id, forIssue: issue) {
                return false
            }
        }
        return true
    }
    
    // Gets a list of unreported contacts
    func unreported() -> [ContactLog] {
        return all.filter({$0.reported == false})
    }
    
    mutating func markAllReported(_ logs: [ContactLog]) {
        logs.forEach { self.markReported($0) }
    }
    
    // Marks a contact as reported.  This will have no effect if there
    // is no matching ContactLog in our list of contacts.
    mutating func markReported(_ log: ContactLog) {
        if let index = all.index(of: log) {
            // ContactLogs are immutable, so we'll need to replace it
            all.remove(at: index)
            all.append(ContactLog(issueId: log.issueId, contactId: log.contactId, phone: log.phone, outcome: log.outcome, date: log.date, reported: true))
        }
    }
    
    static private var filePath: URL {
        let pantryDirName = "com.thatthinginswift.pantry"
        let appSupportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!

        let targetPath: URL
        if AppDelegate.isRunningUnitTests {
            targetPath = FileManager.default.temporaryDirectory.appendingPathComponent(ContactLogs.persistenceKey, isDirectory: false)
        } else {
            targetPath = URL(fileURLWithPath: appSupportDir).appendingPathComponent(pantryDirName).appendingPathComponent(ContactLogs.persistenceKey, isDirectory: false)
        }

        return targetPath
    }    
}

extension ContactLogs {
    func save() {
        let wrapper = LegacyPantryWrapper(expires: 0, storage: self.all)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(wrapper) {
            try? data.write(to: ContactLogs.filePath)
        }
    }
    
    static func load() -> ContactLogs {
        if let fileData = try? Data(contentsOf: ContactLogs.filePath) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let wrapper = try? decoder.decode(LegacyPantryWrapper.self, from: fileData) {
                return ContactLogs(logs: wrapper.storage)
            }
        }
        
        // can't decode contact logs? make a new one
        return ContactLogs()
    }
    
    static func removeData() {
        try? FileManager.default.removeItem(at: ContactLogs.filePath)
    }
}
