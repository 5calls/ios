//
//  UserDefaultsKeys.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

enum UserDefaultsKeys : String {
    case hasShownWelcomeScreen
    case zipCode
    case locationInfo
    case locationDisplay
    case locationType
}

extension UserDefaults {
    func getValue(forKey key: UserDefaultsKeys) -> String? {
        return string(forKey: key.rawValue)
    }
}
