// Copyright 5calls. All rights reserved. See LICENSE for details.

import XCTest
@testable import FiveCalls

final class CountingViewTests: XCTestCase {
    func milestone(_ count: Int) -> CGFloat {
        CountingView(title: "Calls", count: count).nextMilestone
    }

    func testHandPickedMilestones() {
        XCTAssertEqual(milestone(20), 100)
        XCTAssertEqual(milestone(12_600_000), 15_000_000)
        XCTAssertEqual(milestone(14_499_999), 15_000_000)
    }

    func testMilestonesPastFifteenMillion() {
        XCTAssertEqual(milestone(14_500_000), 20_000_000)
        XCTAssertEqual(milestone(19_499_999), 20_000_000)
        XCTAssertEqual(milestone(19_500_000), 25_000_000)
        XCTAssertEqual(milestone(42_000_000), 45_000_000)
    }

    func testMilestoneIsAlwaysAheadOfCount() {
        for count in stride(from: 0, through: 100_000_000, by: 250_000) {
            XCTAssertGreaterThan(milestone(count), CGFloat(count), "milestone not ahead of \(count)")
        }
    }
}
