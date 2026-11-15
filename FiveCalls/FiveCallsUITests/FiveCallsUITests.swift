// Copyright 5calls. All rights reserved. See LICENSE for details.

import XCTest
@testable import FiveCalls

class FiveCallsUITests: XCTestCase {
    var app: XCUIApplication!

    @MainActor override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment = ["UI_TESTING": "1"]
        loadJSONFixtures(application: app)
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    @MainActor func testTakeScreenshots() {
        app.buttons["Get Started"].tap()

        // set location
        app.buttons["Set your location"].tap()
        app.textFields["locationField"].tap()
        app.textFields["locationField"].typeText("94110")
        app.textFields["locationField"].typeText("\r")

        // select first issue
        app.collectionViews.cells.element(boundBy: 0).tap()
        snapshot("1-issue-detail")

        app.swipeUp()
        app.buttons["See your script"].tap()
        snapshot("2-script")

        app.swipeUp()
        // nav to second contact that has more phone numbers
        app.buttons["Contact"].tap()
        // open the more phones menu
        app.buttons["localNumbers"].tap()

        snapshot("3-local-numbers")
    }

    @MainActor func testRepNoticeShownAboveReps() throws {
        app.terminate()
        app.launchEnvironment["GET:/v1/reps"] = try repsFixtureWithNotice()
        app.launch()

        if app.buttons["Get Started"].waitForExistence(timeout: 3) {
            app.buttons["Get Started"].tap()
        }
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Set your location'")).firstMatch.tap()
        app.textFields["locationField"].tap()
        app.textFields["locationField"].typeText("94110")
        app.textFields["locationField"].typeText("\r")

        let issue = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Call House Rep'")).firstMatch
        XCTAssertTrue(issue.waitForExistence(timeout: 5))
        issue.tap()
        XCTAssertTrue(app.descendants(matching: .any)["repNotice"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["Reps"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["repNotice"].waitForExistence(timeout: 5))
    }

    /// Built from the shared fixture at runtime so testTakeScreenshots, which uses that fixture for
    /// the App Store screenshots, doesn't get a notice.
    private func repsFixtureWithNotice() throws -> String {
        let bundle = Bundle(for: FiveCallsUITests.self)
        let fixture = try XCTUnwrap(bundle.url(forResource: "GET-v1-reps-UI", withExtension: "json"))
        var reps = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(contentsOf: fixture)) as? [String: Any])
        reps["isSplit"] = false
        reps["notice"] = [
            "id": 1,
            "text": "New members of Congress take office in January 2027. Until then, these are your current representatives.",
            "expiresAt": "2099-01-04T00:00:00Z",
        ]
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GET-v1-reps-notice.json")
        try JSONSerialization.data(withJSONObject: reps).write(to: url)
        return url.path
    }

    private func loadJSONFixtures(application: XCUIApplication) {
        let bundle = Bundle(for: FiveCallsUITests.self)
        application.launchEnvironment["GET:/v1/reps"] = bundle.path(forResource: "GET-v1-reps-UI", ofType: "json")
        application.launchEnvironment["GET:/v1/issues"] = bundle.path(forResource: "GET-v1-issues-UI", ofType: "json")
        application.launchEnvironment["GET:/v1/report"] = bundle.path(forResource: "GET-v1-report", ofType: "json")
    }
}
