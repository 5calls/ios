//
//  ContactLog.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/5/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import RswiftResources

struct ContactLog : Hashable, Codable {
    let issueId: String
    let contactId: String
    let phone: String
    let outcome: String
    let date: Date
    let reported: Bool

    static func localizedOutcomeForStatus(status: String) -> String {
        switch status {
        case "vm", "voicemail":
            return R.string.localizableR.outcomesVoicemail()
        case "contact", "contacted":
            return R.string.localizableR.outcomesContact()
        case "unavailable":
            return R.string.localizableR.outcomesUnavailable()
        case "skip":
            return R.string.localizableR.outcomesSkip()
        default:
            return "Unknown"
        }
    }
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

    // MARK: the file path for locally saved contact logs that was inherited from pantry

    static private var filePath: URL {
        let pantryDirName = "com.thatthinginswift.pantry"
        let appSupportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!

        let targetPath: URL
        if AppDelegate.isRunningUnitTests {
            targetPath = FileManager.default.temporaryDirectory
        } else {
            targetPath = URL(fileURLWithPath: appSupportDir).appendingPathComponent(pantryDirName)
        }

        // don't try to create a directory with the full path, even with "isDirectory: false"
        try? FileManager.default.createDirectory(at: targetPath, withIntermediateDirectories: true)

        return targetPath.appendingPathComponent(ContactLogs.persistenceKey, isDirectory: false)
    }
}

extension ContactLogs {
    func save() {
        let wrapper = LegacyPantryWrapper(expires: 0, storage: self.all)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(wrapper) {
            do {
                try data.write(to: ContactLogs.filePath)
            } catch {
                AnalyticsManager.shared.trackError(error: error)
            }
        }
    }

    static func debugContactLogs() {
        print("file should be at \(ContactLogs.filePath)")

        let pantryDirName = "com.thatthinginswift.pantry"
        let appSupportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        let files = try? FileManager.default.contentsOfDirectory(atPath: URL(fileURLWithPath: appSupportDir).appendingPathComponent(pantryDirName).path)

        print("directory is \(String(describing: files))")
    }

    static func load() -> ContactLogs {
//        ContactLogs.debugContactLogs()

        // check for the file first, not having a file is not an error we want to log
        if FileManager.default.fileExists(atPath: ContactLogs.filePath.path),
           let fileData = try? Data(contentsOf: ContactLogs.filePath) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let wrapper = try? decoder.decode(LegacyPantryWrapper.self, from: fileData) {
                return ContactLogs(logs: wrapper.storage)
            } else {
                print("couldn't decode wrapper")
                AnalyticsManager.shared.trackError(error: ContactLogError.CantDecodeWrapper)
            }
        }

        // can't decode contact logs? make a new one
        return ContactLogs()
    }

    static func removeData() {
        try? FileManager.default.removeItem(at: ContactLogs.filePath)
    }
}

enum ContactLogError: Error {
    case CantDecodeWrapper
}
