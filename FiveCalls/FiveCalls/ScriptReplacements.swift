//
//  ScriptReplacements.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 12/12/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation
import RegexBuilder

struct ScriptReplacements {
    static func replacing(script: String, contact: Contact, location: NewUserLocation?) -> String {
        var replacedScript = ScriptReplacements.chooseSubscript(script: script, contact: contact)

        replacedScript = ScriptReplacements.replacingContact(script: replacedScript, contact: contact)

        if let location {
            replacedScript = ScriptReplacements.replacingLocation(script: replacedScript, location: location)
        }

        return replacedScript
    }

    static func chooseSubscript(script: String, contact: Contact) -> String {
        let houseIntroPattern = /\*{2}WHEN CALLING HOUSE:\*{2}\n/
        let senateIntroPattern = /\*{2}WHEN CALLING SENATE:\*{2}\n/

        func wholeRegex(_ introPattern: Regex<Substring>) -> Regex<Substring> {
            return Regex {
                introPattern
                OneOrMore(.anyNonNewline)
                OneOrMore(.newlineSequence)
            }
        }

        if contact.area == "US House" || contact.area == "House" {
            let replacedScript = script.replacing(Regex(houseIntroPattern), with: "")
            return replacedScript.replacing(wholeRegex(senateIntroPattern), with: "")
        } else if contact.area == "US Senate" || contact.area == "Senate" {
            let replacedScript =  script.replacing(Regex(senateIntroPattern), with: "")
            return replacedScript.replacing(wholeRegex(houseIntroPattern), with: "")
        }

        return script
    }

    static func replacingContact(script: String, contact: Contact) -> String {
        let pattern = /\[REP\/SEN NAME\]|\[SENATOR\/REP NAME\]|\[SENATOR NAME\]|\[REPRESENTATIVE NAME\]/
        let template = contact.title.map { $0 + " " + contact.name } ?? contact.name
        return script.replacing(Regex(pattern), with: template)
    }

    static func replacingLocation(script: String, location: NewUserLocation) -> String {
        let pattern = /\[CITY,\s?ZIP\]|\[CITY,\s?STATE\]/
        return script.replacing(Regex(pattern), with: location.locationDisplay)
    }
}

extension Contact {
    var title: String? {
        switch self.area {
        case "US House", "House":
            return R.string.localizable.titleUsHouse()
        case "US Senate", "Senate":
            return R.string.localizable.titleUsSenate()
        case "StateLower", "StateUpper":
            return R.string.localizable.titleStateRep()
        case "Governor":
            return R.string.localizable.titleGovernor()
        case "AttorneyGeneral":
            return R.string.localizable.titleAttorneyGeneral()
        case "SecretaryOfState":
            return R.string.localizable.titleSecretaryOfState()
        default:
            // return nothing for unknown
            return nil
        }
    }
}
