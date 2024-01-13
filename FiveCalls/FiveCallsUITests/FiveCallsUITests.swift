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
        
    @MainActor override func setUp() {
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
    
    private func loadJSONFixtures(application: XCUIApplication) {
        let bundle = Bundle(for: FiveCallsUITests.self)
        application.launchEnvironment["GET:/v1/reps"] = bundle.path(forResource: "GET-v1-reps-UI", ofType: "json")
        application.launchEnvironment["GET:/v1/issues"] = bundle.path(forResource: "GET-v1-issues-UI", ofType: "json")
        application.launchEnvironment["GET:/v1/report"] = bundle.path(forResource: "GET-v1-report", ofType: "json")
    }
}
