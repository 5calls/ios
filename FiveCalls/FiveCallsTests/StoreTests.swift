//
//  StoreTests.swift
//  FiveCallsTests
//
//  Created by Christopher Selin on 1/5/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import SwiftUI
import XCTest
@testable import FiveCalls

let kError = NSError(domain: "Test Error", code: 0)

final class StoreTests: XCTestCase {
    func testReduceShowWelcomeScreen() throws {
        let store = Store(state: AppState())
        XCTAssertFalse(store.state.showWelcomeScreen)
        _ = store.reduce(store.state, .ShowWelcomeScreen)
        XCTAssertTrue(store.state.showWelcomeScreen)
    }

    func testReduceSetGlobalCallCount() throws {
        let store = Store(state: AppState())
        XCTAssertEqual(store.state.globalCallCount, 0)
        _ = store.reduce(store.state, .SetGlobalCallCount(5))
        XCTAssertEqual(store.state.globalCallCount, 5)
    }

    func testReduceSetIssueCallCount() throws {
        let store = Store(state: AppState())
        let issueID = 123
        XCTAssertNil(store.state.issueCallCounts[issueID])
        _ = store.reduce(store.state, .SetIssueCallCount(issueID, 1))
        XCTAssertEqual(store.state.issueCallCounts[issueID], 1)
    }

    func testReduceSetDonateOn() throws {
        let store = Store(state: AppState())
        XCTAssertFalse(store.state.donateOn)
        _ = store.reduce(store.state, .SetDonateOn(true))
        XCTAssertTrue(store.state.donateOn)
        _ = store.reduce(store.state, .SetDonateOn(false))
        XCTAssertFalse(store.state.donateOn)
    }

    func testReduceSetIssueContactCompletion() throws {
        let state = AppState()
        let issueID = 123
        // reset cache
        state.issueCompletion[issueID] = nil
        let store = Store(state: state)
        XCTAssertNil(store.state.issueCompletion[issueID])
        _ = store.reduce(store.state, .SetIssueContactCompletion(issueID, "unavailable"))
        XCTAssertEqual(store.state.issueCompletion[issueID], ["unavailable"])
        _ = store.reduce(store.state, .SetIssueContactCompletion(issueID, "contacted"))
        XCTAssertEqual(store.state.issueCompletion[issueID], ["unavailable", "contacted"])
    }

    func testReduceSetFetchingContacts() throws {
        let store = Store(state: AppState())
        XCTAssertFalse(store.state.fetchingContacts)
        _ = store.reduce(store.state, .SetFetchingContacts(true))
        XCTAssertTrue(store.state.fetchingContacts)
        _ = store.reduce(store.state, .SetFetchingContacts(false))
        XCTAssertFalse(store.state.fetchingContacts)
    }

    func testReduceSetIssues() throws {
        let issues = [Issue.basicPreviewIssue]
        let store = Store(state: AppState())
        XCTAssertEqual(store.state.issues, [])
        _ = store.reduce(store.state, .SetIssues(issues))
        XCTAssertEqual(store.state.issues, issues)
    }

    func testReduceSetContacts() throws {
        let contacts = [Contact.housePreviewContact]
        let store = Store(state: AppState())
        XCTAssertEqual(store.state.contacts, [])
        _ = store.reduce(store.state, .SetContacts(contacts))
        XCTAssertEqual(store.state.contacts, contacts)
    }

    func testReduceSetLocation() throws {
        let state = AppState()
        let location = UserLocation(address: "123 Main St")
        // reset cache
        state.location = nil
        let store = Store(state: state)
        XCTAssertNil(store.state.location)
        _ = store.reduce(store.state, .SetLocation(location))
        XCTAssertEqual(store.state.location, location)
    }

    func testReduceSetLoadingStatsError() {
        let store = Store(state: AppState())
        XCTAssertNil(store.state.statsLoadingError)
        _ = store.reduce(store.state, .SetLoadingStatsError(kError))
        XCTAssertEqual(store.state.statsLoadingError! as NSError, kError)
    }

    func testReduceSetLoadingIssuesError() {
        let store = Store(state: AppState())
        XCTAssertNil(store.state.issueLoadingError)
        _ = store.reduce(store.state, .SetLoadingIssuesError(kError))
        XCTAssertEqual(store.state.issueLoadingError! as NSError, kError)
    }

    func testReduceSetLoadingContactsError() {
        let store = Store(state: AppState())
        XCTAssertNil(store.state.contactsLoadingError)
        _ = store.reduce(store.state, .SetLoadingContactsError(kError))
        XCTAssertEqual(store.state.contactsLoadingError! as NSError, kError)
    }

    func testReduceGoBackPathIsEmpty() {
        let state = AppState()
        let issue = Issue.basicPreviewIssue
        state.issueRouter.selectedIssue = issue
        let store = Store(state: state)
        XCTAssertEqual(store.state.issueRouter.selectedIssue, issue)
        XCTAssertTrue(store.state.issueRouter.path.isEmpty)
        _ = store.reduce(store.state, .GoBack)
        XCTAssertNil(store.state.issueRouter.selectedIssue)
    }

    func testReduceGoBackPathNotEmpty() {
        let state = AppState()
        let issue = Issue.basicPreviewIssue
        state.issueRouter.selectedIssue = issue
        state.issueRouter.path.append("SomeValue")
        let store = Store(state: state)
        XCTAssertEqual(store.state.issueRouter.selectedIssue, issue)
        XCTAssertEqual(store.state.issueRouter.path.count, 1)
        _ = store.reduce(store.state, .GoBack)
        XCTAssertEqual(store.state.issueRouter.selectedIssue, issue)
        XCTAssertTrue(store.state.issueRouter.path.isEmpty)
    }

    func testReduceGoToRoot() {
        let state = AppState()
        let issue = Issue.basicPreviewIssue
        state.issueRouter.selectedIssue = issue
        state.issueRouter.path.append("SomeValue")
        let store = Store(state: state)
        XCTAssertEqual(store.state.issueRouter.selectedIssue, issue)
        XCTAssertFalse(store.state.issueRouter.path.isEmpty)
        _ = store.reduce(store.state, .GoToRoot)
        XCTAssertNil(store.state.issueRouter.selectedIssue)
        XCTAssertTrue(store.state.issueRouter.path.isEmpty)
    }

    func testReduceGoToNext() {
        let store = Store(state: AppState())
        let issue = Issue.basicPreviewIssue
        let contacts = [Contact.housePreviewContact, Contact.senatePreviewContact1]
        XCTAssertTrue(store.state.issueRouter.path.isEmpty)
        _ = store.reduce(store.state, .GoToNext(issue, contacts))
        XCTAssertFalse(store.state.issueRouter.path.isEmpty)
        var path = NavigationPath()
        path.append(IssueDetailNavModel(issue: issue, contacts: contacts))
        XCTAssertEqual(store.state.issueRouter.path, path)
    }

    func testReduceGoToNextLastContact() {
        let store = Store(state: AppState())
        let issue = Issue.basicPreviewIssue
        XCTAssertTrue(store.state.issueRouter.path.isEmpty)

        var path = NavigationPath()
        _ = store.reduce(store.state, .GoToNext(issue, [.senatePreviewContact1,.housePreviewContact]))
        path.append(IssueDetailNavModel(issue: issue, contacts: [.senatePreviewContact1,.housePreviewContact]))
        XCTAssertEqual(store.state.issueRouter.path, path)
        
        _ = store.reduce(store.state, .GoToNext(issue, [.housePreviewContact]))
        path.append(IssueDetailNavModel(issue: issue, contacts: [.housePreviewContact]))
        XCTAssertEqual(store.state.issueRouter.path, path)
        
        _ = store.reduce(store.state, .GoToNext(issue, []))
        path.append(IssueNavModel(issue: issue, type: "done"))
        XCTAssertEqual(store.state.issueRouter.path, path)
    }
}
