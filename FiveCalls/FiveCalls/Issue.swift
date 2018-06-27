//
//  Issue.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import Down
import Rswift

struct Issue {
    let id: String
    let name: String
    let reason: NSAttributedString
    let script: NSAttributedString
    let category: Category?
    let inactive: Bool
    let contacts: [Contact]
    let outcomes: [Outcome]

    static var style: String {        
        if let bytes = try? Data(resource: R.file.issuesStyleCss)  {
            return String(decoding: bytes, as: UTF8.self)
        }
        return ""
    }
}

extension Issue : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let reason = dictionary["reason"] as? String,
            let script = dictionary["script"] as? String,
            let contactsJSON = dictionary["contacts"] as? [JSONDictionary],
            let outcomesJSON = dictionary["outcomeModels"] as? [JSONDictionary],
            let categoriesJSON = dictionary["categories"] as? [JSONDictionary],
            let inactive = dictionary["inactive"] as? Bool
        else {
            print("Unable to parse JSON as Issue: \(dictionary)")
            return nil
        }
        
        let contacts = contactsJSON.compactMap({ Contact(dictionary: $0) })
        let outcomes = outcomesJSON.compactMap({ Outcome(dictionary: $0) })
        let category = categoriesJSON.compactMap({ Category(dictionary: $0) }).first
        
        var attributedReason = NSAttributedString(string: reason)
        var markdown = Down.init(markdownString: reason)
        if let converted = try? markdown.toAttributedString(.default, stylesheet: Issue.style) {
            attributedReason = converted
        }
        
        var attributedScript = NSAttributedString(string: script)
        markdown = Down.init(markdownString: script)
        if let converted = try? markdown.toAttributedString(.default, stylesheet: Issue.style) {
            attributedScript = converted
        }
        
        self.init(id: id, name: name, reason: attributedReason, script: attributedScript, category: category, inactive: inactive, contacts: contacts, outcomes: outcomes)
    }
}
