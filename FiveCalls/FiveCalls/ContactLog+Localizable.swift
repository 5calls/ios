//
//  ContactLog+Localizable.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 7/5/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import Foundation
import Rswift

extension ContactLog {
    var localizedOutcome: String {
        switch outcome {
        case "vm", "voicemail":
            return R.string.localizable.outcomesVoicemail()
        case "contact", "contacted":
            return R.string.localizable.outcomesContact()
        case "unavailable":
            return R.string.localizable.outcomesUnavailable()
        case "skip":
            return R.string.localizable.outcomesSkip()
        default:
            return "Unknown"
        }
    }
}
