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

    init(id: String = "id", area: String = "US House", name: String = "Test Name", party: String = "Party", phone: String = "14155551212", photoURL: URL? = nil, fieldOffices: [AreaOffice] = []) {
        self.id = id
        self.area = area
        self.name = name
        self.party = party
        self.phone = phone
        self.photoURL = photoURL
        self.reason = nil
        self.state = nil
        self.fieldOffices = fieldOffices
    }
}

extension Contact: Hashable, Identifiable {
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
    
    // this has some overlap with other area -> string conversions but I haven't thought about it long enough to combine them
    func officeDescription() -> String {
        switch self.area {
        case "US House", "House":
            // TODO: plumb the district through here too
            return "\(R.string.localizable.usHouse()) \(self.state ?? "")"
        case "US Senate", "Senate":
            return "\(R.string.localizable.usSenate()) \(self.state ?? "")"
        case "StateLower", "StateUpper":
            return "\(R.string.localizable.stateRep()) \(self.state ?? "")"
        case "Governor":
            return "\(R.string.localizable.governor()) \(self.state ?? "")"
        case "AttorneyGeneral":
            return "\(R.string.localizable.attorneyGeneral()) \(self.state ?? "")"
        case "SecretaryOfState":
            return "\(R.string.localizable.secretaryOfState()) \(self.state ?? "")"
        default:
            return ""
        }
    }
}

extension Contact {
    static func placeholderContact(for area: String) -> [Contact] {
        switch area {
        case "US House":
            return [
                    Contact(id: "1234", area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: []),
                    Contact(id: "1235", area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: [])
                ]
        default:
            return [Contact(id: "1234", area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: [])]
        }
    }
}

// AreaToNiceString converts an area name to a generic office name that can be used in the interface
func AreaToNiceString(area: String) -> String {
    switch area {
    case "US House", "House":
        return "House Rep";
    case "US Senate", "Senate":
        return "Senators";
    // state legislatures call themselves different things by state, so let's use a generic term for all of them
    case "StateLower", "StateUpper":
        return "State Reps";
    case "Governor":
        return "Governor";
    case "AttorneyGeneral":
        return "Attorney General";
    case "SecretaryOfState":
        return "Secretary of State";
    default:
        return area
    }
}
