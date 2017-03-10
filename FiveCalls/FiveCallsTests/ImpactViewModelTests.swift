//
//  ImpactViewModelTests.swift
//  FiveCalls
//
//  Created by Nikrad Mahdi on 3/9/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

class ImpactViewModelTests: XCTestCase {
    
    let dates: [Date] = [
        Date(timeIntervalSince1970: TimeInterval(1478649600)), // Wed, 09 Nov 2016 00:00:00 GMT
        Date(timeIntervalSince1970: TimeInterval(1485928846)), // Wed, 01 Feb 2017 06:00:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1485930046)), // Wed, 01 Feb 2017 06:20:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1486123200)), // Fri, 03 Feb 2017 12:00:00 GMT
        Date(timeIntervalSince1970: TimeInterval(1486706446)), // Fri, 10 Feb 2017 06:00:46 GMT
        Date(timeIntervalSince1970: TimeInterval(1487073600)), // Tue, 14 Feb 2017 12:00:00 GMT
    ]
    
    func testWeeksApart() {
        let t1 = dates[1]
        let expected = [12, 0, 0, 0, 1, 2]
        for (index, t2) in dates.enumerated() {
            XCTAssertEqual(ImpactViewModel.weeksApart(from: t1, to: t2), expected[index])
            XCTAssertEqual(ImpactViewModel.weeksApart(from: t2, to: t1), expected[index])
        }
    }
    
    func testCountWeeklyStreak() {
        // No calls
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [], now: Date()), 0)
        // Single call right now
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[0]], now: dates[0]), 1)
        // Single call last week
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[1]], now: dates[4]), 1)
        // Single call this week
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[1]], now: dates[2]), 1)
        // Single call two weeks ago
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[1]], now: dates[5]), 0)
        // Two calls this week
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[1], dates[2]], now: dates[3]), 1)
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[2], dates[1]], now: dates[3]), 1)
        // One call this week, one call last week
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[1], dates[4]], now: dates[4]), 2)
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[4], dates[1]], now: dates[4]), 2)
        // One call last week, one call the week before that
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[1], dates[4]], now: dates[5]), 2)
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[4], dates[1]], now: dates[5]), 2)
        // One call this week, one call last week, three calls the week before
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: [dates[4], dates[3], dates[1], dates[5], dates[2]], now: dates[5]), 3)
        XCTAssertEqual(ImpactViewModel.countWeeklyStreak(callDates: dates, now: dates[5]), 3)
    }
}
