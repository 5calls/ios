//
//  FiveCallsUITests.swift
//  FiveCallsUITests
//
//  Created by Ben Scheirman on 2/8/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

class FiveCallsUITests: XCTestCase {

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment = ["UI_TESTING" : "1"]
        loadJSONFixtures(application: app)
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTakeScreenshots() {
        snapshot("0-welcome")
        
        // ¯\_(ツ)_/¯
        let welcomeScreen = app.otherElements.containing(.image, identifier:"5calls-logotype")
            .children(matching: .other).element(boundBy: 1)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element

        welcomeScreen.swipeLeft()

        snapshot("1-welcome2")

        app.buttons["GET STARTED"].tap()
        app.buttons["Set Location"].tap()
        app.textFields["Zip or Address"].tap()
        app.typeText("77429")
        app.buttons["SUBMIT"].tap()

        snapshot("2-issues")
 
        // this break in the future as new issues come out, but I think it's better to pick an issue explicitly
        // rather than tapping on the first cell. Having canned data for UI_TESTING is a good solution to this.
        app.tables.element(boundBy: 0).swipeUp()
        app.tables.cells.staticTexts["Defend the Affordable Care Act"].tap()
        snapshot("3-issue-detail")
        let issueTable = app.tables.element(boundBy: 0)
        issueTable.swipeUp()
        issueTable.swipeUp()
        
        app.cells.staticTexts["Ted Cruz"].tap()
        snapshot("4-call-script")
    }
    
    private func loadJSONFixtures(application: XCUIApplication) {
        let bundle = Bundle(for: FiveCallsUITests.self)
        application.launchEnvironment["GET:/issues"] = bundle.path(forResource: "GET-issues", ofType: "json")
        application.launchEnvironment["GET:/report"] = bundle.path(forResource: "GET-report", ofType: "json")
        application.launchEnvironment["POST:/report"] = bundle.path(forResource: "POST-report", ofType: "json")
    }
}
