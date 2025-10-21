// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation

struct ImpactViewModel {
    let userStats: UserStats?
    let logs: ContactLogs

    init(logs: ContactLogs, stats: UserStats?) {
        self.logs = logs
        userStats = stats
    }

    var numberOfCalls: Int {
        (userStats?.totalCalls() ?? 0) + logs.unreported().count
    }

    var madeContactCount: Int {
        (userStats?.contact ?? 0) + logs.unreported().count(where: { $0.outcome == "contact" || $0.outcome == "contacted" })
    }

    var unavailableCount: Int {
        (userStats?.unavailable ?? 0) + logs.unreported().count(where: { $0.outcome == "unavailable" })
    }

    var voicemailCount: Int {
        (userStats?.voicemail ?? 0) + logs.unreported().count(where: { $0.outcome == "voicemail" || $0.outcome == "vm" })
    }

    var weeklyStreakCount: Int {
        // Eventually the server will calculate call streaks and report them when we pull
        // stats, but for now we are sourcing that data locally.
        let logDates = logs.all.map(\.date)
        return StreakCounter(dates: logDates, referenceDate: Date()).weekly
    }

    var weeklyStreakMessage: String {
        // use the server weekly streak if available
        let weeklyStreakCount = userStats?.weeklyStreak ?? weeklyStreakCount

        switch weeklyStreakCount {
        case 0:
            return String(
                localized: "Your current weekly call streak is 0.",
                comment: "Weekly streak for zero"
            )
        case 1:
            return String(
                localized: "Your current weekly call streak just started. Keep it going!",
                comment: "Weekly call streak single"
            )
        default:
            return String(
                localized: "Your current weekly call streak is \(weeklyStreakCount) weeks in a row. You're on a roll!",
                comment: "Weekly call streak multiples"
            )
        }
    }

    var impactMessage: String {
        String(
            localized: "Your total impact is \(numberOfCalls) calls.",
            comment: "Pluralized number of calls impact message"
        )
    }
}
