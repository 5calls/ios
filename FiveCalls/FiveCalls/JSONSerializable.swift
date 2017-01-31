//
//  JSONSerializable.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String:Any]

protocol JSONSerializable {
    init?(dictionary: JSONDictionary)
}
