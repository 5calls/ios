// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

enum RatingPromptCounter {
    private static let threshold = 5

    static func increment(handler: () -> Void) {
        let defaults = UserDefaults.standard
        let key = UserDefaultsKey.countOfCallsForRatingPrompt.rawValue
        let count = defaults.integer(forKey: key) + 1

        guard count <= threshold else { return }

        defaults.set(count, forKey: key)

        if count == threshold {
            handler()
        }
    }
}
