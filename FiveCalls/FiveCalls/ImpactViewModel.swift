//
//  ImpactViewModel.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct ImpactViewModel {
    
    let userStats: UserStats?
    let logs: ContactLogs
    
    init(logs: ContactLogs, stats: UserStats?) {
        self.logs = logs
        self.userStats = stats
    }
    
    var numberOfCalls: Int {
        return (userStats?.totalCalls() ?? 0) + logs.unreported().count
    }
    
    var madeContactCount: Int {
        return (userStats?.contact ?? 0) + logs.unreported().filter { $0.outcome == "contact" || $0.outcome == "contacted" }.count
    }
    
    var unavailableCount: Int {
        return (userStats?.unavailable ?? 0) + logs.unreported().filter { $0.outcome == "unavailable" }.count
    }
    
    var voicemailCount: Int {
        return (userStats?.voicemail ?? 0) + logs.unreported().filter { $0.outcome == "voicemail" || $0.outcome == "vm" }.count
    }
    
    var weeklyStreakCount: Int {
        // Eventually the server will calculate call streaks and report them when we pull
        // stats, but for now we are sourcing that data locally.
        let logDates = logs.all.map { $0.date }
        return StreakCounter(dates: logDates, referenceDate: Date()).weekly
    }

    var weeklyStreakMessage: String {
        // use the server weekly streak if available
        let weeklyStreakCount = self.userStats?.weeklyStreak ?? self.weeklyStreakCount

        switch weeklyStreakCount {
        case 0:
            return R.string.localizableR.yourWeeklyStreakZero(weeklyStreakCount)
        case 1:
            return R.string.localizableR.yourWeeklyStreakSingle()
        default:
            return R.string.localizableR.yourWeeklyStreakMultiple(weeklyStreakCount)
        }
    }

    var impactMessage: String {
        switch self.numberOfCalls {
        case 0:
            return R.string.localizableR.yourImpactZero(numberOfCalls)
        case 1:
            return R.string.localizableR.yourImpactSingle(numberOfCalls)
        default:
            return R.string.localizableR.yourImpactMultiple(numberOfCalls)
        }
    }

}
