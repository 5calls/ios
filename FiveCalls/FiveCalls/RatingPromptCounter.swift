//
//  RatingPromptCounter.swift
//  FiveCalls
//
//  Created by Abizer Nasir on 09/10/2017.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct RatingPromptCounter {
    private let threshold = 5

    let handler: (() -> Void)?

    func increment() {
        let defaults = UserDefaults.standard
        let key = UserDefaultsKey.countOfCallsForRatingPrompt.rawValue
        let count = defaults.integer(forKey: key) + 1

        guard count <= threshold else { return }

        defaults.set(count, forKey: key)

        if count == threshold {
            handler?()
        }
    }
}
