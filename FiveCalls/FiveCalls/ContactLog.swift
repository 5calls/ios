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
    private let store: ContactLogsStore
    var all: [ContactLog]
    
    /// Returns an empty set, storing new data in the provided store.
    static func empty(store: ContactLogsStore) -> ContactLogs {
        ContactLogs(store: store, logs: [])
    }
    
    fileprivate init(store: ContactLogsStore, logs: [ContactLog]) {
        self.store = store
        all = logs
    }
    
    /// Returns all logs that have been created since a given date
    func since(date: Date) -> [ContactLog] {
        all.filter { $0.date > date }
    }

    mutating func add(log: ContactLog) {
        all.append(log)
        store.save(logs: self)
        NotificationCenter.default.post(name: .callMade, object: log)
    }
    
    func methodOfContact(to contactId: String, forIssue issue: Issue) -> String? {
        return all.filter({$0.contactId == contactId && ($0.issueId == String(issue.id) || $0.issueId == issue.meta)}).last?.outcome
    }

    func hasContacted(contact: Contact, forIssue issue: Issue) -> Bool {
        guard let method = methodOfContact(to: contact.id, forIssue: issue) else {
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
    
    // Gets a list of unreported contacts
    func unreported() -> [ContactLog] {
        return all.filter({$0.reported == false})
    }

    // MARK: mutating functions
    
    mutating func save() {
        store.save(logs: self)
    }
    
    mutating func markAllReported(_ logs: [ContactLog]) {
        logs.forEach { self.markReported($0) }
    }
    
    // Marks a contact as reported.  This will have no effect if there
    // is no matching ContactLog in our list of contacts.
    mutating func markReported(_ log: ContactLog) {
        if let index = all.firstIndex(of: log) {
            // ContactLogs are immutable, so we'll need to replace it
            all.remove(at: index)
            all.append(ContactLog(issueId: log.issueId, contactId: log.contactId, phone: log.phone, outcome: log.outcome, date: log.date, reported: true))
        }
    }
}

enum ContactLogError: Error {
    case CantDecodeWrapper
}

protocol ContactLogsStore {
    func save(logs: ContactLogs)
    func load() -> ContactLogs
    func removeData()
}

class FileContactLogsStore: ContactLogsStore {
    let url: URL
    private let analytics: Analytics
    
    init(url: URL, analytics: Analytics) {
        self.url = url
        self.analytics = analytics
    }
    
    func save(logs: ContactLogs) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let wrapper = LegacyPantryWrapper(expires: 0, storage: logs.all)
        if let data = try? encoder.encode(wrapper) {
            do {
                try data.write(to: url)
            } catch {
                analytics.trackError(error: error)
            }
        }
    }
    
    func load() -> ContactLogs {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            // no file yet, return a new one
            return .empty(store: self)
        }
        
        guard let fileData = try? Data(contentsOf: url),
              let wrapper = try? decoder.decode(LegacyPantryWrapper.self, from: fileData) else {
            analytics.trackError(error: ContactLogError.CantDecodeWrapper)
            return .empty(store: self)
        }
        
        return ContactLogs(store: self, logs: wrapper.storage)
    }
    
    func removeData() {
        try? FileManager.default.removeItem(at: url)
    }
}


