//
//  IssueDetailWarningTests.swift
//  FiveCallsTests
//
//  Created by Claude Code on 9/16/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import XCTest
import SwiftUI
@testable import FiveCalls

final class IssueDetailWarningTests: XCTestCase {

    // MARK: - Test Data Setup

    private func createTestStore(contactsLowAccuracy: Bool, contacts: [Contact] = []) -> Store {
        let state = AppState()
        state.contactsLowAccuracy = contactsLowAccuracy
        state.contacts = contacts
        state.location = UserLocation(address: "123 Test St")
        return Store(state: state)
    }

    private static let stateUpperContact = Contact(
        id: "state-upper-1",
        area: "StateUpper",
        name: "State Rep Upper",
        party: "Democrat",
        phone: "415-555-0001"
    )

    private static let stateLowerContact = Contact(
        id: "state-lower-1",
        area: "StateLower",
        name: "State Rep Lower",
        party: "Republican",
        phone: "415-555-0002"
    )

    private static let houseContact = Contact.housePreviewContact
    private static let senateContact = Contact.senatePreviewContact1

    // MARK: - Store Reducer Tests

    func testSetContactsLowAccuracyReducer() {
        let store = createTestStore(contactsLowAccuracy: false)

        // Initially false
        XCTAssertFalse(store.state.contactsLowAccuracy)

        // Set to true
        _ = store.reduce(store.state, .SetContactsLowAccuracy(true))
        XCTAssertTrue(store.state.contactsLowAccuracy)

        // Set back to false
        _ = store.reduce(store.state, .SetContactsLowAccuracy(false))
        XCTAssertFalse(store.state.contactsLowAccuracy)
    }


    // MARK: - Warning Logic Tests

    func testIssueDetailWarningLogicShouldShowWarningWhenConditionsMet() {
        // Test the standalone logic function directly
        let result = IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: true,
            issueContactAreas: ["StateUpper", "StateLower"]
        )
        XCTAssertTrue(result, "Should show warning when low accuracy and state reps present")
    }

    func testIssueDetailWarningLogicShouldHideWarningWhenLowAccuracyFalse() {
        // Test the standalone logic function directly
        let result = IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: false,
            issueContactAreas: ["StateUpper", "StateLower"]
        )
        XCTAssertFalse(result, "Should NOT show warning when accuracy is normal")
    }

    func testIssueDetailWarningLogicShouldHideWarningWhenNoStateReps() {
        // Test the standalone logic function directly
        let result = IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: true,
            issueContactAreas: ["US House", "US Senate"]
        )
        XCTAssertFalse(result, "Should NOT show warning when no state reps")
    }

    func testIssueDetailWarningLogicHasStateRepsDetection() {
        // Test StateUpper detection
        XCTAssertTrue(
            IssueDetailWarningLogic.hasStateReps(in: ["StateUpper"]),
            "Should detect StateUpper"
        )

        // Test StateLower detection
        XCTAssertTrue(
            IssueDetailWarningLogic.hasStateReps(in: ["StateLower"]),
            "Should detect StateLower"
        )

        // Test both
        XCTAssertTrue(
            IssueDetailWarningLogic.hasStateReps(in: ["StateUpper", "StateLower"]),
            "Should detect both StateUpper and StateLower"
        )

        // Test federal only
        XCTAssertFalse(
            IssueDetailWarningLogic.hasStateReps(in: ["US House", "US Senate"]),
            "Should NOT detect state reps in federal areas"
        )

        // Test mixed
        XCTAssertTrue(
            IssueDetailWarningLogic.hasStateReps(in: ["US House", "StateUpper", "Governor"]),
            "Should detect state reps in mixed areas"
        )

        // Test empty
        XCTAssertFalse(
            IssueDetailWarningLogic.hasStateReps(in: []),
            "Should NOT detect state reps in empty array"
        )
    }

    func testIssueDetailWarningLogicWithRealIssueData() {
        // Test with actual issue data to ensure compatibility

        // State-specific issue with low accuracy = should show warning
        let stateIssueResult = IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: true,
            issueContactAreas: Issue.stateSpecificPreviewIssue.contactAreas
        )
        XCTAssertTrue(stateIssueResult, "State-specific issue with low accuracy should show warning")

        // State-specific issue with normal accuracy = should NOT show warning
        let stateIssueNormalAccuracy = IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: false,
            issueContactAreas: Issue.stateSpecificPreviewIssue.contactAreas
        )
        XCTAssertFalse(stateIssueNormalAccuracy, "State-specific issue with normal accuracy should NOT show warning")

        // Federal issue with low accuracy = should NOT show warning
        let federalIssueResult = IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: true,
            issueContactAreas: Issue.basicPreviewIssue.contactAreas
        )
        XCTAssertFalse(federalIssueResult, "Federal issue should NOT show warning even with low accuracy")

        // Mixed issue (no state reps) with low accuracy = should NOT show warning
        let mixedIssueResult = IssueDetailWarningLogic.shouldShowWarning(
            contactsLowAccuracy: true,
            issueContactAreas: Issue.manyContactPreviewIssue.contactAreas
        )
        XCTAssertFalse(mixedIssueResult, "Mixed issue (no state reps) should NOT show warning")
    }

    func testIssueDetailWarningLogicHasStateRepsWithRealData() {
        // Test hasStateReps function with real issue data

        // State-specific issue should have state reps
        XCTAssertTrue(
            IssueDetailWarningLogic.hasStateReps(in: Issue.stateSpecificPreviewIssue.contactAreas),
            "State-specific issue should have state reps"
        )

        // Federal issue should NOT have state reps
        XCTAssertFalse(
            IssueDetailWarningLogic.hasStateReps(in: Issue.basicPreviewIssue.contactAreas),
            "Federal issue should NOT have state reps"
        )

        // Mixed issue should NOT have state reps
        XCTAssertFalse(
            IssueDetailWarningLogic.hasStateReps(in: Issue.manyContactPreviewIssue.contactAreas),
            "Mixed issue should NOT have state reps"
        )
    }
}
