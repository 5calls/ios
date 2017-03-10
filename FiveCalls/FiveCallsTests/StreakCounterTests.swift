//
//  StreakCounterTests.swift
//  FiveCalls
//
//  Created by Nikrad Mahdi on 3/10/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

class StreakCounterTests: XCTestCase {
    
    let dates: [Date] = [
        Date(timeIntervalSince1970: TimeInterval(1478649600)), // Wed, 09 Nov 2016 00:00:00 GMT
        Date(timeIntervalSince1970: TimeInterval(1485928846)), // Wed, 01 Feb 2017 06:00:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1485930046)), // Wed, 01 Feb 2017 06:20:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1486016446)), // Thu, 02 Feb 2017 06:20:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1486102846)), // Fri, 03 Feb 2017 06:20:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1486706446)), // Fri, 10 Feb 2017 06:00:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1487073600)), // Tue, 14 Feb 2017 12:00:00 GMT
    ]
    
    func testDaysApart() {
        let t1 = dates[1]
        let expected = [84, 0, 0, 1, 2, 9, 14]
        for (index, t2) in dates.enumerated() {
            XCTAssertEqual(StreakCounter.daysApart(from: t1, to: t2), expected[index])
            XCTAssertEqual(StreakCounter.daysApart(from: t2, to: t1), expected[index])
        }
    }
    
    func testWeeksApart() {
        let t1 = dates[1]
        let expected = [12, 0, 0, 0, 0, 1, 2]
        for (index, t2) in dates.enumerated() {
            XCTAssertEqual(StreakCounter.weeksApart(from: t1, to: t2), expected[index])
            XCTAssertEqual(StreakCounter.weeksApart(from: t2, to: t1), expected[index])
        }
    }
    
    func testDailyStreak() {
        // No events
        var streak = StreakCounter(dates: [], referenceDate: Date())
        XCTAssertEqual(streak.daily, 0)
        // Single event right now
        streak = StreakCounter(dates: [dates[0]], referenceDate: dates[0])
        XCTAssertEqual(streak.daily, 1)
        // Single event yesterday
        streak = StreakCounter(dates: [dates[2]], referenceDate: dates[3])
        XCTAssertEqual(streak.daily, 1)
        // Single event this today
        streak = StreakCounter(dates: [dates[2]], referenceDate: dates[1])
        XCTAssertEqual(streak.daily, 1)
        // Single event two days ago
        streak = StreakCounter(dates: [dates[4]], referenceDate: dates[2])
        XCTAssertEqual(streak.daily, 0)
        // Two events today
        streak = StreakCounter(dates: [dates[1], dates[2]], referenceDate: dates[2])
        XCTAssertEqual(streak.daily, 1)
        streak = StreakCounter(dates: [dates[2], dates[1]], referenceDate: dates[2])
        XCTAssertEqual(streak.daily, 1)
        // One event today, one event yesterday
        streak = StreakCounter(dates: [dates[2], dates[3]], referenceDate: dates[3])
        XCTAssertEqual(streak.daily, 2)
        streak = StreakCounter(dates: [dates[3], dates[2]], referenceDate: dates[3])
        XCTAssertEqual(streak.daily, 2)
        // One event yesterday, one event the day before that
        streak = StreakCounter(dates: [dates[2], dates[3]], referenceDate: dates[4])
        XCTAssertEqual(streak.daily, 2)
        streak = StreakCounter(dates: [dates[3], dates[2]], referenceDate: dates[4])
        XCTAssertEqual(streak.daily, 2)
        // One event today, one event yesterday, and two events the day before that
        streak = StreakCounter(dates: [dates[4], dates[0], dates[1], dates[3], dates[2]], referenceDate: dates[4])
        XCTAssertEqual(streak.daily, 3)
        streak = StreakCounter(dates: Array(self.dates[0...4]), referenceDate: dates[4])
        XCTAssertEqual(streak.daily, 3)
    }
    
    func testWeeklyStreak() {
        // No events
        var streak = StreakCounter(dates: [], referenceDate: Date())
        XCTAssertEqual(streak.weekly, 0)
        // Single event right now
        streak = StreakCounter(dates: [dates[0]], referenceDate: dates[0])
        XCTAssertEqual(streak.weekly, 1)
        // Single event last week
        streak = StreakCounter(dates: [dates[1]], referenceDate: dates[5])
        XCTAssertEqual(streak.weekly, 1)
        // Single event this week
        streak = StreakCounter(dates: [dates[1]], referenceDate: dates[2])
        XCTAssertEqual(streak.weekly, 1)
        // Single event two weeks ago
        streak = StreakCounter(dates: [dates[1]], referenceDate: dates[6])
        XCTAssertEqual(streak.weekly, 0)
        // Two events this week
        streak = StreakCounter(dates: [dates[1], dates[2]], referenceDate: dates[3])
        XCTAssertEqual(streak.weekly, 1)
        streak = StreakCounter(dates: [dates[2], dates[1]], referenceDate: dates[3])
        XCTAssertEqual(streak.weekly, 1)
        // One event this week, one event last week
        streak = StreakCounter(dates: [dates[1], dates[5]], referenceDate: dates[5])
        XCTAssertEqual(streak.weekly, 2)
        streak = StreakCounter(dates: [dates[5], dates[1]], referenceDate: dates[5])
        XCTAssertEqual(streak.weekly, 2)
        // One event last week, one event the week before that
        streak = StreakCounter(dates: [dates[1], dates[5]], referenceDate: dates[6])
        XCTAssertEqual(streak.weekly, 2)
        streak = StreakCounter(dates: [dates[5], dates[1]], referenceDate: dates[6])
        XCTAssertEqual(streak.weekly, 2)
        // One event this week, one event last week, three events the week before
        streak = StreakCounter(dates: [dates[5], dates[3], dates[1], dates[6], dates[2]], referenceDate: dates[6])
        XCTAssertEqual(streak.weekly, 3)
        streak = StreakCounter(dates: dates, referenceDate: dates[6])
        XCTAssertEqual(streak.weekly, 3)
    }
}
