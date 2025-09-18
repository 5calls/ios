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
    // this has some overlap with other area -> string conversions but I haven't thought about it long enough to combine them
    func officeDescription() -> String {
        switch self.area {
        case "US House", "House":
            // TODO: plumb the district through here too
            return "\(Bundle.Strings.usHouse) \(self.state ?? "")"
        case "US Senate", "Senate":
            return "\(Bundle.Strings.usSenate) \(self.state ?? "")"
        case "StateLower", "StateUpper":
            return "\(Bundle.Strings.stateRep) \(self.state ?? "")"
        case "Governor":
            return "\(Bundle.Strings.governor) \(self.state ?? "")"
        case "AttorneyGeneral":
            return "\(Bundle.Strings.attorneyGeneral) \(self.state ?? "")"
        case "SecretaryOfState":
            return "\(Bundle.Strings.secretaryOfState) \(self.state ?? "")"
        default:
            return ""
        }
    }
}

extension Contact {
    static func placeholderContact(for area: String) -> [Contact] {
        switch area {
        case "US Senate":
            return [
                    Contact(id: "1234", area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: []),
                    Contact(id: "1235", area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: [])
                ]
        default:
            // list views will complain if we have mutiple placeholders with the same ID so randomize them
            return [Contact(id: String(Int.random(in: 0..<999)), area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: [])]
        }
    }
}

// AreaToNiceString converts an area name to a generic office name that can be used in the interface
func AreaToNiceString(area: String) -> String {
    switch area {
    case "US House", "House":
        return Bundle.Strings.groupingUsHouse
    case "US Senate", "Senate":
        return Bundle.Strings.groupingUsSenate
    // state legislatures call themselves different things by state, so let's use a generic term for all of them
    case "StateLower", "StateUpper":
        return Bundle.Strings.groupingStateRep
    case "Governor":
        return Bundle.Strings.groupingGovernor
    case "AttorneyGeneral":
        return Bundle.Strings.groupingAttorneyGeneral
    case "SecretaryOfState":
        return Bundle.Strings.groupingSecretaryOfState
    default:
        return area
    }
}
