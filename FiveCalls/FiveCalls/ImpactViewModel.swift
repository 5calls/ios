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
        return logs.filter { $0.outcome == .contacted }.count
    }
    
    var unavailableCount: Int {
        return logs.filter { $0.outcome == .unavailable }.count
    }
    
    var voicemailCount: Int {
        return logs.filter { $0.outcome == .voicemail }.count
    }
    
    var weeklyStreakCount: Int {
        let logDates = logs.map { $0.date }
        return ImpactViewModel.countWeeklyStreak(callDates: logDates, now: Date())
    }
    
    static func countWeeklyStreak(callDates: [Date], now: Date) -> Int {
        var count = 0
        // No calls ever made
        if (callDates.count == 0) {
            return count
        }
        
        let callDatesDescending = callDates.sorted(by: { (d1, d2) -> Bool in
            return d1 > d2
        })
        
        let lastCallDate = callDatesDescending[0]
        guard let weeksSinceLastCall = self.weeksApart(from: lastCallDate, to: now) else {
            return count
        }
        
        // It has been more than a week since the last recorded call
        if (weeksSinceLastCall > 1) {
            return count
        }
        
        // There has been at least one call this week or last week
        count += 1
        if (callDates.count == 1) {
            return count
        }
        
        var prevCallDate = lastCallDate
        for nextCallDate in callDatesDescending[1...(callDatesDescending.count - 1)] {
            guard let weeksSinceLastCall = self.weeksApart(from: nextCallDate, to: prevCallDate) else {
                break
            }
            
            // Stop counting when the gap exceeds a week
            if (weeksSinceLastCall > 1) {
                break
            }
            
            if (weeksSinceLastCall == 1) {
                count += 1
            }
            
            prevCallDate = nextCallDate
        }
        
        return count
    }
    
    static func weeksApart(from: Date, to: Date) -> Int? {
        var calendar = Calendar.current
        // Start weeks on Mondays
        calendar.firstWeekday = 2
        let calComponents: Set<Calendar.Component> = [.weekOfYear, .yearForWeekOfYear]
        guard let fromDate = calendar.date(from: calendar.dateComponents(calComponents, from: from)) else {
            return nil
        }
        guard let toDate = calendar.date(from: calendar.dateComponents(calComponents, from: to)) else {
            return nil
        }
        
        let dateComponents = calendar.dateComponents([.weekOfYear], from: fromDate, to: toDate)
        guard let weeks = dateComponents.weekOfYear else {
            return nil
        }
        
        return abs(weeks)
    }
}
