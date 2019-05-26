//
//  ContactList.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/9/19.
//  Copyright © 2019 5calls. All rights reserved.
//

import Foundation

class ContactList : Decodable {
    let location: String
    let representatives: [Contact]
}
