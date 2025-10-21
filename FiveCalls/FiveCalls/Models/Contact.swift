// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

struct Contact: Decodable, Identifiable {
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
        photoURL = try (container.decode(String?.self, forKey: .photoURL)).flatMap(URL.init)
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
        reason = nil
        state = nil
        self.fieldOffices = fieldOffices
    }
}

extension Contact: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }
}

extension Contact {
    // this has some overlap with other area -> string conversions but I haven't thought about it long enough to combine them
    func localizedOfficeDescription() -> LocalizedStringResource {
        switch area {
        case "US House", "House":
            // TODO: plumb the district through here too
            "\(String(localized: "US House Rep", comment: "Office Holder description")) \(state ?? "")"
        case "US Senate", "Senate":
            "\(String(localized: "US Senator", comment: "Office Holder description")) \(state ?? "")"
        case "StateLower", "StateUpper":
            "\(String(localized: "State Rep", comment: "Office Holder description")) \(state ?? "")"
        case "Governor":
            "\(String(localized: "Governor Office", defaultValue: "Governor", comment: "Office Holder description")) \(state ?? "")"
        case "AttorneyGeneral":
            "\(String(localized: "Attorney General Office", defaultValue: "Attorney General", comment: "Office Holder description")) \(state ?? "")"
        case "SecretaryOfState":
            "\(String(localized: "Secretary of State Office", defaultValue: "Secretary of State", comment: "Office Holder description")) \(state ?? "")"
        default:
            ""
        }
    }
}

extension Contact {
    static func placeholderContact(for area: String) -> [Contact] {
        switch area {
        case "US Senate":
            [
                Contact(id: "1234", area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: []),
                Contact(id: "1235", area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: []),
            ]
        default:
            // list views will complain if we have mutiple placeholders with the same ID so randomize them
            [Contact(id: String(Int.random(in: 0 ..< 999)), area: area, name: area, party: area, phone: "", photoURL: nil, fieldOffices: [])]
        }
    }
}

extension Contact {
    var title: String? {
        switch area {
        case "US House", "House":
            String(localized: "Rep.", comment: "Office Holder title")
        case "US Senate", "Senate":
            String(localized: "Senator", comment: "Office Holder title")
        case "StateLower", "StateUpper":
            String(localized: "Legislator", comment: "Office Holder title")
        case "Governor":
            String(localized: "Governor Title", defaultValue: "Governor", comment: "Office Holder title")
        case "AttorneyGeneral":
            String(localized: "Attorney General Title", defaultValue: "Attorney General", comment: "Office Holder title")
        case "SecretaryOfState":
            String(localized: "Secretary of State Title", defaultValue: "Secretary of State", comment: "Office Holder title")
        default:
            // return nothing for unknown
            nil
        }
    }
}

// AreaToNiceString converts an area name to a generic office name that can be used in the interface
func areaToNiceString(area: String) -> String {
    switch area {
    case "US House", "House":
        String(localized: "House Rep", comment: "Office Holder grouping description")
    case "US Senate", "Senate":
        String(localized: "Senators", comment: "Office Holder grouping description")
    // state legislatures call themselves different things by state, so let's use a generic term for all of them
    case "StateLower", "StateUpper":
        String(localized: "State Reps", comment: "Office Holder grouping description")
    case "Governor":
        String(localized: "Governor Grouping", defaultValue: "Governor", comment: "Office Holder grouping description")
    case "AttorneyGeneral":
        String(localized: "Attorney General Grouping", defaultValue: "Attorney General", comment: "Office Holder grouping description")
    case "SecretaryOfState":
        String(localized: "Secretary of State Grouping", defaultValue: "Secretary of State", comment: "Office Holder grouping description")
    default:
        area
    }
}
