// Copyright 5calls. All rights reserved. See LICENSE for details.

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
    let weeklyStreak: Int?
}

extension UserStats: JSONSerializable {
    init?(dictionary: JSONDictionary) {
        let weeklyStreak = dictionary["weeklyStreak"] as? Int

        var contact: Int?
        var voicemail: Int?
        var unavailable: Int?
        if let stats = dictionary["stats"] as? JSONDictionary {
            contact = stats["contact"] as? Int
            voicemail = stats["voicemail"] as? Int
            unavailable = stats["unavailable"] as? Int
        }

        self.init(contact: contact,
                  voicemail: voicemail,
                  unavailable: unavailable,
                  weeklyStreak: weeklyStreak)
    }

    func totalCalls() -> Int {
        (contact ?? 0) + (voicemail ?? 0) + (unavailable ?? 0)
    }
}
