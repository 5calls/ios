// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

struct AreaOffice: Decodable, Identifiable {
    let city: String
    let phone: String

    var id: Int {
        phone.hashValue
    }
}
