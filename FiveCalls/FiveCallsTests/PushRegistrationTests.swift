// Copyright 5calls. All rights reserved. See LICENSE for details.

import UserNotifications
import XCTest
@testable import FiveCalls

final class PushRegistrationTests: XCTestCase {
    func testRegistersWhenAllowed() {
        for hasToken in [true, false] {
            XCTAssertEqual(PushRegistration.syncAction(status: .authorized, hasStoredToken: hasToken), .register)
            XCTAssertEqual(PushRegistration.syncAction(status: .provisional, hasStoredToken: hasToken), .register)
        }
    }

    func testUnregistersWhenTurnedOffInSettings() {
        XCTAssertEqual(PushRegistration.syncAction(status: .denied, hasStoredToken: true), .unregister)
    }

    func testDoesNothingWhenDeniedWithoutToken() {
        // declined the prompt outright, or we already removed the token
        XCTAssertEqual(PushRegistration.syncAction(status: .denied, hasStoredToken: false), .none)
    }

    func testDoesNothingWhenNeverAsked() {
        XCTAssertEqual(PushRegistration.syncAction(status: .notDetermined, hasStoredToken: false), .none)
    }
}
