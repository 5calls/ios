// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

class ContactList: Decodable {
    let location: String
    let lowAccuracy: Bool
    let isSplit: Bool
    let state: String
    let district: String
    let representatives: [Contact]
    // optional message to show above the reps, see RepNotice
    let notice: RepNotice?

    var generalizedLocationID: String {
        "\(state)-\(district)"
    }

    private enum CodingKeys: String, CodingKey {
        case location, lowAccuracy, isSplit, state, district, representatives, notice
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        location = try container.decode(String.self, forKey: .location)
        lowAccuracy = try container.decode(Bool.self, forKey: .lowAccuracy)
        isSplit = try container.decode(Bool.self, forKey: .isSplit)
        state = try container.decode(String.self, forKey: .state)
        district = try container.decode(String.self, forKey: .district)
        representatives = try container.decode([Contact].self, forKey: .representatives)
        // a malformed notice should never cost the user their reps
        notice = try? container.decodeIfPresent(RepNotice.self, forKey: .notice)
    }
}
