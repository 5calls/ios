//
//  ImpactViewModel.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation

struct ImpactViewModel {
    let logs: [ContactLog]
    
    init(logs: [ContactLog]) {
        self.logs = logs
    }
    
    var numberOfCalls: Int {
        return logs.count
    }
    
    var madeContactCount: Int {
        return logs.filter { $0.outcome == "contact" || $0.outcome == "contacted" }.count
    }
    
    var unavailableCount: Int {
        return logs.filter { $0.outcome == "unavailable" }.count
    }
    
    var voicemailCount: Int {
        return logs.filter { $0.outcome == "voicemail" || $0.outcome == "vm" }.count
    }
    
    var weeklyStreakCount: Int {
        let logDates = logs.map { $0.date }
        return StreakCounter(dates: logDates, referenceDate: Date()).weekly
    }
}
