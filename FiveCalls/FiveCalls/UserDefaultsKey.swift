// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

enum UserDefaultsKey: String {
    case hasShownWelcomeScreen

    case locationDisplay
    case locationType
    case locationValue
    case stateAbbreviation // cached state abbreviation from contacts API

    case issueCompletionCache // a cached map of issue id to contact ids regarding completed calls

    case hasSeenFirstCallInstructions
    case reminderEnabled

    case appVersion // The current CFBundleShortVersionString
    case countOfCallsForRatingPrompt

    case lastAskedForNotificationPermission

    case selectIssuePath

    case callerID // an anoymous unique id, sometimes the old firebase userid
    case callingGroup // a calling group is a group that tallies their calls together
}
