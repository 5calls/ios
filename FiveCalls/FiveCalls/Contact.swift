//
//  Contact.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct Contact : Decodable, Identifiable {
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

    // Used for placeholder generation - I don't think the whole object is used, just the `area` parameter
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

extension Contact: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Contact {    
    // this has some overlap with other area -> string conversions but I haven't thought about it long enough to combine them
    func localizedOfficeDescription() -> LocalizedStringResource {
        switch self.area {
        case "US House", "House":
            // TODO: plumb the district through here too
            return "\(String(localized: "US House Rep", comment: "Office Holder description")) \(self.state ?? "")"
        case "US Senate", "Senate":
            return "\(String(localized: "US Senator", comment: "Office Holder description")) \(self.state ?? "")"
        case "StateLower", "StateUpper":
            return "\(String(localized: "State Rep", comment: "Office Holder description")) \(self.state ?? "")"
        case "Governor":
            return "\(String(localized: "Governor Office", defaultValue: "Governor", comment: "Office Holder description")) \(self.state ?? "")"
        case "AttorneyGeneral":
            return "\(String(localized: "Attorney General Office", defaultValue: "Attorney General", comment: "Office Holder description")) \(self.state ?? "")"
        case "SecretaryOfState":
            return "\(String(localized: "Secretary of State Office", defaultValue: "Secretary of State", comment: "Office Holder description")) \(self.state ?? "")"
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

extension Contact {
    var title: String? {
        switch self.area {
        case "US House", "House":
            return String(localized: "Rep.", comment: "Office Holder title")
        case "US Senate", "Senate":
            return String(localized: "Senator", comment: "Office Holder title")
        case "StateLower", "StateUpper":
            return String(localized: "Legislator", comment: "Office Holder title")
        case "Governor":
            return String(localized: "Governor Title", defaultValue: "Governor", comment: "Office Holder title")
        case "AttorneyGeneral":
            return String(localized: "Attorney General Title", defaultValue: "Attorney General", comment: "Office Holder title")
        case "SecretaryOfState":
            return String(localized: "Secretary of State Title", defaultValue: "Secretary of State", comment: "Office Holder title")
        default:
            // return nothing for unknown
            return nil
        }
    }
}


// AreaToNiceString converts an area name to a generic office name that can be used in the interface
func areaToNiceString(area: String) -> String {
    switch area {
    case "US House", "House":
        return String(localized: "House Rep", comment: "Office Holder grouping description")
    case "US Senate", "Senate":
        return String(localized: "Senators", comment: "Office Holder grouping description")
    // state legislatures call themselves different things by state, so let's use a generic term for all of them
    case "StateLower", "StateUpper":
        return String(localized: "State Reps", comment: "Office Holder grouping description")
    case "Governor":
        return String(localized: "Governor Grouping", defaultValue: "Governor", comment: "Office Holder grouping description")
    case "AttorneyGeneral":
        return String(localized: "Attorney General Grouping", defaultValue: "Attorney General", comment: "Office Holder grouping description")
    case "SecretaryOfState":
        return String(localized: "Secretary of State Grouping", defaultValue: "Secretary of State", comment: "Office Holder grouping description")
    default:
        return area
    }
}

