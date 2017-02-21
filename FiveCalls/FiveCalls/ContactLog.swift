//
//  ContactLog.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/5/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import Pantry

extension Date {
    static let secondsPerHour: TimeInterval = 60 * 60
    static let secondsPerDay: TimeInterval = 60 * 60 * 24
}

enum ContactOutcome : String {
    case contacted
    case voicemail = "vm"
    case unavailable
    
    // reserved for cases where we save something on disk that we later don't recognize
    case unknown
}

struct ContactLog {

    let issueId: String
    let contactId: String
    let phone: String
    let outcome: ContactOutcome
    let date: Date
    
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
}

extension ContactLog : Storable {
    static let unavailableStalenessTimeout: TimeInterval = Date.secondsPerHour * 12    //if a call marked as 'unavailable' is older than this limit, we remove it from the log
    
    init?(warehouse: Warehouseable) {
        issueId = warehouse.get("issueId") ?? ""
        contactId = warehouse.get("contactId") ?? ""
        phone = warehouse.get("phone") ?? ""
        outcome = warehouse.get("outcome").flatMap(ContactOutcome.init) ?? .unknown
        date = ContactLog.dateFormatter.date(from: warehouse.get("date") ?? "") ?? Date()
        
        if isOldAndUnavailable {
            print("Removing old available log from \(date)")
            return nil
        }
    }
    
    var isOldAndUnavailable: Bool {
        return outcome == .unavailable && -date.timeIntervalSinceNow > ContactLog.unavailableStalenessTimeout
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "issueId": issueId,
            "contactId": contactId,
            "phone": phone,
            "outcome": outcome.rawValue,
            "date": ContactLog.dateFormatter.string(from: date)
        ]
    }
}

extension ContactLog : Hashable {
    var hashValue: Int {
        return (issueId + contactId + phone + outcome.rawValue).hash
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
    
    mutating func clearOldUnavailable() {
        for call in all {
            if call.isOldAndUnavailable, let index = all.index(of: call) {
                all.remove(at: index)
            }
        }
    }
    
    var hasOldAndUnavailableCalls: Bool {
        for call in all {
            if call.isOldAndUnavailable { return true }
        }
        return false
    }
    
    func save() {
        Pantry.pack(all, key: ContactLogs.persistenceKey)
    }
    
    static func load() -> ContactLogs {
        return Pantry.unpack(persistenceKey).flatMap(ContactLogs.init) ?? ContactLogs()
    }
    
    func methodOfContact(to contactId: String, forIssue issueId: String) -> ContactOutcome? {
        return all.filter({$0.contactId == contactId && $0.issueId == issueId}).last?.outcome
    }
	
    func hasContacted(contactId: String, forIssue issueId: String) -> Bool {
        return self.methodOfContact(to: contactId, forIssue: issueId) != nil
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
