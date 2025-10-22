// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

struct Issue: Identifiable, Decodable {
    let id: Int
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

    var shareImageURL: URL {
        URL(string: String(format: "https://api.5calls.org/v1/issue/%d/share/t", id))!
    }

    var shareURL: URL {
        URL(string: String(format: "https://5calls.org/issue/%@/", slug.trimmingCharacters(in: .whitespacesAndNewlines)))!
    }

    var hasHouse: Bool { contactAreas.contains("US House") }

    var hasSenate: Bool { contactAreas.contains("US Senate") }

    // contactsForIssue takes a list of all contacts and returns a consistently sorted list of
    // contacts based on the areas for this issue
    func contactsForIssue(allContacts: [Contact]) -> [Contact] {
        var sortedContacts: [Contact] = []

        for area in sortedContactAreas(areas: contactAreas) {
            sortedContacts.append(contentsOf: allContacts.filter { area == $0.area })
        }

        return sortedContacts
    }

    // returns any contacts that should be displayed on the issue, but aren't actually targetted
    // this ensures both house and senate reps are displayed even when the issue specifically targets one or the other
    func irrelevantContacts(allContacts: [Contact]) -> [Contact] {
        var irrelevantContacts: [Contact] = []

        if hasHouse, !hasSenate {
            let senateContacts = allContacts.filter { $0.area == "US Senate" }
            irrelevantContacts.append(contentsOf: senateContacts)
        }

        if hasSenate, !hasHouse {
            let houseContacts = allContacts.filter { $0.area == "US House" }
            irrelevantContacts.append(contentsOf: houseContacts)
        }
        return irrelevantContacts
    }

    // returns the contact area that is not relevant to a congressional issue
    // either US House, US Senate, or nil
    func irrelevantContactArea() -> String? {
        if hasHouse, !hasSenate {
            return "US Senate"
        }

        if hasSenate, !hasHouse {
            return "US House"
        }

        return nil
    }

    // sortedContactAreas takes a list of contact areas and orders them in our preferred order,
    // we should always order them properly on the server but let's do this to be sure
    func sortedContactAreas(areas: [String]) -> [String] {
        var contactAreas: [String] = []

        // TODO: convert these to enums when they are parsed in json
        for area in ["StateLower", "StateUpper", "US House", "US Senate", "Governor", "AttorneyGeneral", "SecretaryOfState"] {
            if areas.contains(area) {
                contactAreas.append(area)
            }
        }

        // add any others at the end
        contactAreas.append(contentsOf: areas.filter { !["StateLower", "StateUpper", "US House", "US Senate", "Governor", "AttorneyGeneral", "SecretaryOfState"].contains($0) })

        return contactAreas
    }

    // Check if this issue is state-specific based on meta field containing state abbreviation
    var isStateSpecific: Bool {
        !meta.isEmpty && stateNameFromAbbreviation != nil
    }

    // Get full state name from abbreviation in meta field
    var stateNameFromAbbreviation: String? {
        let stateMap: [String: String] = [
            "AK": "Alaska",
            "AL": "Alabama",
            "AR": "Arkansas",
            "AZ": "Arizona",
            "CA": "California",
            "CO": "Colorado",
            "CT": "Connecticut",
            "DE": "Delaware",
            "FL": "Florida",
            "GA": "Georgia",
            "HI": "Hawaii",
            "IA": "Iowa",
            "ID": "Idaho",
            "IL": "Illinois",
            "IN": "Indiana",
            "KS": "Kansas",
            "KY": "Kentucky",
            "LA": "Louisiana",
            "MA": "Massachusetts",
            "MD": "Maryland",
            "ME": "Maine",
            "MI": "Michigan",
            "MN": "Minnesota",
            "MO": "Missouri",
            "MS": "Mississippi",
            "MT": "Montana",
            "NC": "North Carolina",
            "ND": "North Dakota",
            "NE": "Nebraska",
            "NH": "New Hampshire",
            "NJ": "New Jersey",
            "NM": "New Mexico",
            "NV": "Nevada",
            "NY": "New York",
            "OH": "Ohio",
            "OK": "Oklahoma",
            "OR": "Oregon",
            "PA": "Pennsylvania",
            "RI": "Rhode Island",
            "SC": "South Carolina",
            "SD": "South Dakota",
            "TN": "Tennessee",
            "TX": "Texas",
            "UT": "Utah",
            "VA": "Virginia",
            "VT": "Vermont",
            "WA": "Washington",
            "WI": "Wisconsin",
            "WV": "West Virginia",
            "WY": "Wyoming",
            "DC": "District of Columbia",
        ]
        return stateMap[meta.uppercased()]
    }
}

extension Issue: Equatable, Hashable {
    static func == (lhs: Issue, rhs: Issue) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
