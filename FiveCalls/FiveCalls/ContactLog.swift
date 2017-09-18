//
//  ContactLog.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/5/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import Pantry

struct ContactLog {

    let issueId: String
    let contactId: String
    let phone: String
    let outcome: String
    let date: Date
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
}

extension ContactLog : Storable {

    init(warehouse: Warehouseable) {
        issueId = warehouse.get("issueId") ?? ""
        contactId = warehouse.get("contactId") ?? ""
        phone = warehouse.get("phone") ?? ""
        outcome = warehouse.get("outcome") ?? "unknown"
        date = ContactLog.dateFormatter.date(from: warehouse.get("date") ?? "") ?? Date()
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "issueId": issueId,
            "contactId": contactId,
            "phone": phone,
            "outcome": outcome,
            "date": ContactLog.dateFormatter.string(from: date)
        ]
    }
}

extension ContactLog : Hashable {
    var hashValue: Int {
        return (issueId + contactId + phone + outcome).hash
    }
    
    static func ==(lhs: ContactLog, rhs: ContactLog) -> Bool {
        return lhs.issueId == rhs.issueId &&
                lhs.contactId == rhs.contactId &&
                lhs.phone == rhs.phone &&
                lhs.outcome == rhs.outcome
    }
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
    
    func save() {
        Pantry.pack(all, key: ContactLogs.persistenceKey)
    }
    
    static func load() -> ContactLogs {
        return Pantry.unpack(persistenceKey).flatMap(ContactLogs.init) ?? ContactLogs()
    }
    
    func methodOfContact(to contactId: String, forIssue issueId: String) -> String? {
        return all.filter({$0.contactId == contactId && $0.issueId == issueId}).last?.outcome
    }

    func hasContacted(contactId: String, forIssue issueId: String) -> Bool {
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
    
    func hasCompleted(issue: String, allContacts: [Contact]) -> Bool {
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
}
