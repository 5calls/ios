//
//  UserDefaultsKey.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

enum UserDefaultsKey : String {
    case hasShownWelcomeScreen
    
    case locationDisplay
    case locationType
    case locationValue
    
    case hasSeenFirstCallInstructions
    case reminderEnabled

    case appVersion // The current CFBundleShortVersionString
    case countOfCallsForRatingPrompt
    
    case lastAskedForNotificationPermission

    case selectIssuePath
}
