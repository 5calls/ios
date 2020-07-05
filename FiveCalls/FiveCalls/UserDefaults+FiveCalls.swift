//
//  UserDefaults+FiveCalls.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var fiveCalls: UserDefaults {
        UserDefaults(suiteName: "group.org.fivecalls")!
    }
}
