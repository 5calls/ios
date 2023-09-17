//
//  Issue.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import Rswift

struct Issue: Identifiable, Decodable {
    let id: Int64
    let meta: String
    let name: String
    let slug: String
    let reason: String
    let script: String
    let categories: [Category]
    let active: Bool
    let outcomeModels: [Outcome]
    let contactType: String
    let contactAreas: [String]
    let createdAt: Date
    
    var shareURL: URL {
        return URL(string: String(format: "https://api.5calls.org/v1/issue/%d/share/t",self.id))!
    }
    
    // contactsForIssue takes a list of all contacts and returns a consistently sorted list of
    // contacts based on the areas for this issue
    func contactsForIssue(allContacts: [Contact]) -> [Contact] {
        var sortedContacts: [Contact] = []
        
        for area in sortedContactAreas(areas: contactAreas) {
            // return standin contacts if we haven't loaded contacts yet
            if allContacts.isEmpty {
                sortedContacts.append(contentsOf: Contact.placeholderContact(for: area))
            } else {
                sortedContacts.append(contentsOf: allContacts.filter({ area == $0.area }))
            }
        }

        return sortedContacts
    }
    
    // sortedContactAreas takes a list of contact areas and orders them in our preferred order,
    // we should always order them properly on the server but let's do this to be sure
    func sortedContactAreas(areas: [String]) -> [String] {
        var contactAreas: [String] = []
        
        for area in ["StateLower", "StateUpper", "US House", "US Senate", "Governor", "AttorneyGeneral", "SecretaryOfState"] {
            if areas.contains(area) {
                contactAreas.append(area)
            }
        }
        
        // add any others at the end
        contactAreas.append(contentsOf: areas.filter({ !["StateLower", "StateUpper", "US House", "US Senate", "Governor", "AttorneyGeneral", "SecretaryOfState"].contains($0) }))
                
        return contactAreas
    }
    
    var markdownIssueReason: AttributedString {
        do {
            return try AttributedString(markdown: self.reason, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            // TODO: notify us somehow that markdown parsing failed
            return AttributedString("Could not parse issue markdown, email [hello@5calls.org](mailto:hello@5calls.org)")
        }
    }
    
    var markdownIssueScript: AttributedString {
        do {
            return try AttributedString(markdown: self.script, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            // TODO: notify us somehow that markdown parsing failed
            return AttributedString("Could not parse script markdown, email [hello@5calls.org](mailto:hello@5calls.org)")
        }
    }

}

extension Issue: Equatable, Hashable {
    static func == (lhs: Issue, rhs: Issue) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
