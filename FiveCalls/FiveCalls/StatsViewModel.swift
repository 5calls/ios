// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

struct StatsViewModel {
    let numberOfCalls: Int

    var formattedNumberOfCalls: String! {
        let numberFormatter = NumberFormatter()

        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .decimal

        return numberFormatter.string(from: NSNumber(integerLiteral: numberOfCalls))
    }
}
