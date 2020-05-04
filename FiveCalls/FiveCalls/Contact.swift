//
//  Contact.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct Contact : Decodable {
    let id: String
    let area: String
    let name: String
    let party: String
    let phone: String
    let photoURL: URL?
    let reason: String?
    let state: String?
    let fieldOffices: [AreaOffice]
    
    enum CodingKeys: String, CodingKey {
        case id
        case area
        case name
        case party
        case phone
        case photoURL
        case reason
        case state
        case fieldOffices = "field_offices"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        area = try container.decode(String.self, forKey: .area)
        name = try container.decode(String.self, forKey: .name)
        party = try container.decode(String.self, forKey: .party)
        phone = try container.decode(String.self, forKey: .phone)
        photoURL = (try container.decode(String?.self, forKey: .photoURL)).flatMap(URL.init)
        reason = try container.decode(String.self, forKey: .reason)
        state = try container.decode(String.self, forKey: .state)
        fieldOffices = try container.decode([AreaOffice]?.self, forKey: .fieldOffices) ?? []
    }

    init(id: String = "id", area: String = "US House", name: String = "Test Name", party: String = "Party", phone: String = "14155551212") {
        self.id = id
        self.area = area
        self.name = name
        self.party = party
        self.phone = phone
        self.photoURL = nil
        self.reason = nil
        self.state = nil
        self.fieldOffices = []
    }
}

extension Contact : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Contact {
    func customizeScript(script: String) -> String? {
        let pattern = #"\[REP\/SEN NAME\]|\[SENATOR\/REP NAME\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        var template = "";
        switch self.area {
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
        template = template + " " + self.name

        let fullRange = NSRange(script.startIndex..<script.endIndex, in: script)
        let scriptWithContactName = regex.stringByReplacingMatches(in: script, options: [], range: fullRange, withTemplate: template)
        return scriptWithContactName
    }
}
