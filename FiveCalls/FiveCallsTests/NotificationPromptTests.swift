// Copyright 5calls. All rights reserved. See LICENSE for details.

import UserNotifications
import XCTest
@testable import FiveCalls

final class NotificationPromptTests: XCTestCase {
    let now = Date(timeIntervalSince1970: 1_790_000_000)

    func testDeniedNeverPrompts() {
        // someone who accepted and then turned notifications off in Settings
        // lands here with no "No, thanks" date recorded
        XCTAssertFalse(IssueDone.shouldPromptForNotifications(status: .denied, lastAsked: nil, now: now))

        let longAgo = Calendar.current.date(byAdding: .year, value: -1, to: now)
        XCTAssertFalse(IssueDone.shouldPromptForNotifications(status: .denied, lastAsked: longAgo, now: now))
    }

    func testAlreadyAllowedNeverPrompts() {
        for status: UNAuthorizationStatus in [.authorized, .provisional, .ephemeral] {
            XCTAssertFalse(IssueDone.shouldPromptForNotifications(status: status, lastAsked: nil, now: now), "prompted for status \(status.rawValue)")
        }
    }

    func testNotDeterminedPromptsWhenNeverAsked() {
        XCTAssertTrue(IssueDone.shouldPromptForNotifications(status: .notDetermined, lastAsked: nil, now: now))
    }

    func testNotDeterminedWaitsAMonthAfterDecline() {
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)
        XCTAssertFalse(IssueDone.shouldPromptForNotifications(status: .notDetermined, lastAsked: lastWeek, now: now))

        let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: now)
        XCTAssertTrue(IssueDone.shouldPromptForNotifications(status: .notDetermined, lastAsked: twoMonthsAgo, now: now))
    }
}
