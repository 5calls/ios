// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

typealias JSONDictionary = [String: Any]

protocol JSONSerializable {
    init?(dictionary: JSONDictionary)
}
