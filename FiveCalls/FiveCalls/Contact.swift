//
//  Contact.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation


/*
 "contacts": [
 {
 "area": "Senate",
 "id": "TX-JohnCornyn",
 "name": "John Cornyn",
 "party": "Republican",
 "phone": "202-224-2934",
 "photoURL": "http://bioguide.congress.gov/bioguide/photo/C/C001056.jpg",
 "reason": "This is one of your two senators",
 "state": "TX"
 }
 */

struct Contact {
    let id: String
    let area: String
    let name: String
    let party: String
    let phone: String
    let photoURL: URL?
    let reason: String
    let state: String
}

extension Contact : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        guard let id = dictionary["id"] as? String,
            let area = dictionary["area"] as? String,
            let name = dictionary["name"] as? String,
            let party = dictionary["party"] as? String,
            let phone = dictionary["phone"] as? String,
            let photoURLString = dictionary["photoURL"] as? String,
            let reason = dictionary["reason"] as? String,
            let state = dictionary["state"] as? String else {
                print("Unable to parse Contact from JSON: \(dictionary)")
                return nil
        }
        
        let photoURL = URL(string: photoURLString)
        self.init(id: id, area: area, name: name, party: party, phone: phone, photoURL: photoURL, reason: reason, state: state)
    }
}
