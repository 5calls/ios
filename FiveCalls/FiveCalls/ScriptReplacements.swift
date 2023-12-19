//
//  ScriptReplacements.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 12/12/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation

struct ScriptReplacements {
    static func replacing(script: String, contact: Contact, location: NewUserLocation?) -> String {
        var replacedScript = ScriptReplacements.replacingContact(script: script, contact: contact)
        if let location {
            replacedScript = ScriptReplacements.replacingLocation(script: replacedScript, location: location)
        }
        return replacedScript
    }

    static func replacingContact(script: String, contact: Contact) -> String {
        let pattern = /\[REP\/SEN NAME\]|\[SENATOR\/REP NAME\]/
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
