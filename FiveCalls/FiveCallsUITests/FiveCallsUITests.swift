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
        
        let label = app.staticTexts["Turn your passive participation into active resistance. Facebook likes and Twitter retweets can’t create the change you want to see. Calling your Government on the phone can."]
        label.swipeLeft()
        
        snapshot("1-welcome2")

        app.buttons["GET STARTED"].tap()
        app.buttons["Set Location"].tap()
        app.textFields["Zip or Address"].tap()
        app.typeText("77429")
        app.buttons["SUBMIT"].tap()

        snapshot("2-issues")
        
        app.tables.cells.staticTexts["Defend the Affordable Care Act"].tap()
        snapshot("3-issue-detail")
        let issueTable = app.tables.element(boundBy: 0)
        issueTable.swipeUp()
        issueTable.swipeUp()
        issueTable.swipeUp()
        
        app.cells.staticTexts["Ted Cruz"].tap()
        snapshot("4-call-script")
    }
    
    private func loadJSONFixtures(application: XCUIApplication) {
        let bundle = Bundle(for: FiveCallsUITests.self)
        let env = application.launchEnvironment
        env["GET:/issues"] = bundle.path(forResource: "GET-issues", ofType: "json")
        env["GET:/report"] = bundle.path(forResource: "GET-report", ofType: "json")
        env["POST:/report"] = bundle.path(forResource: "POST-report", ofType: "json")
    }
}
