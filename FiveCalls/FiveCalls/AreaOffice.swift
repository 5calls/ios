//
//  AreaOffice.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct AreaOffice: Decodable, Identifiable {
    let city: String
    let phone: String
    
    var id: Int {
        return phone.hashValue
    }
}
