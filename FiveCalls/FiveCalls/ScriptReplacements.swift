//
//  ScriptReplacements.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 12/12/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

struct ScriptReplacements {
    static func Replacing(script: String, contact: Contact, location: NewUserLocation?) -> String {
        var replacedScript = ScriptReplacements.replacingContact(script: script, contact: contact)
        if let location {
            replacedScript = ScriptReplacements.replacingLocation(script: replacedScript, location: location)
        }
        return replacedScript
    }

    static func replacingContact(script: String, contact: Contact) -> String {
        let pattern = #"\[REP\/SEN NAME\]|\[SENATOR\/REP NAME\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return script
        }

        var template = "";
        switch contact.area {
        case "US House", "House":
            template = "Rep.";
        case "US Senate", "Senate":
            template = "Senator";
        case "StateLower", "StateUpper":
            template = "Legislator";
        case "Governor":
            template = "Governor";
        case "AttorneyGeneral":
            template = "Attorney General";
        case "SecretaryOfState":
            template = "Secretary of State";
        default:
            // nothing, append the name on the empty template
            break
        }
        template = template + " " + contact.name

        let fullRange = NSRange(script.startIndex..<script.endIndex, in: script)
        let scriptWithContactName = regex.stringByReplacingMatches(in: script, options: [], range: fullRange, withTemplate: template)
        return scriptWithContactName
    }
    
    static func replacingLocation(script: String, location: NewUserLocation) -> String {
        let pattern = #"\[CITY,\s?ZIP\]|\[CITY,\s?STATE\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return script
        }

        let fullRange = NSRange(script.startIndex..<script.endIndex, in: script)
        let scriptWithLocation = regex.stringByReplacingMatches(in: script, options: [], range: fullRange, withTemplate: location.locationDisplay)
        return scriptWithLocation
    }
}
