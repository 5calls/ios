// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

class ContactList: Decodable {
    let location: String
    let lowAccuracy: Bool
    let isSplit: Bool
    let state: String
    let district: String
    let representatives: [Contact]

    var generalizedLocationID: String {
        "\(state)-\(district)"
    }
}
