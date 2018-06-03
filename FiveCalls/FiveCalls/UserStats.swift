//
//  UserStats.swift
//  FiveCalls
//
//  Created by Melville Stanley on 3/5/18.
//  Copyright © 2018 5calls. All rights reserved.
//

// We expect the JSON to look like this:
// {
//    "contact": 221,
//    "voicemail": 158,
//    "unavailable": 32
// }

struct UserStats {
    let contact: Int?
    let voicemail: Int?
    let unavailable: Int?
}

extension UserStats : JSONSerializable {
    init?(dictionary: JSONDictionary) {
        let contact = dictionary["contact"] as? Int;
        let voicemail = dictionary["voicemail"] as? Int;
        let unavailable = dictionary["unavailable"] as? Int;
        self.init(contact: contact, voicemail: voicemail, unavailable: unavailable)
    }
    
    func totalCalls() -> Int {
        return (contact ?? 0) + (voicemail ?? 0) + (unavailable ?? 0)
    }
    
}
