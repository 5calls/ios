//
//  AreaOffice.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct AreaOffice {
    let city: String
    let phone: String
}

extension AreaOffice : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        guard let city = dictionary["city"] as? String,
        let phone = dictionary["phone"] as? String else {
            return nil
        }
        
        self.city = city
        self.phone = phone
    }
}
