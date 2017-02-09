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
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTakeScreenshots() {
        snapshot("0-welcome")


        app.scrollViews.element(boundBy: 0).swipeLeft()

        snapshot("1-welcome2")

        app.buttons["Get Started"].tap()
        app.buttons["Set Location"].tap()
        app.textFields.element(boundBy: 0).typeText("77429")
        app.buttons["Submit"].tap()

    }

    func testExample() {
        
        let app = XCUIApplication()
        let element = app.otherElements.containing(.image, identifier:"5calls-logotype").children(matching: .other).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.swipeLeft()

        app.buttons["GET STARTED"].tap()


        // about screen
        app.buttons["About 5 Calls"].tap()
        app.navigationBars["About"].buttons["Done"].tap()

        // my impact
        app.buttons["My Impact"].tap()
        app.navigationBars["My Impact"].buttons["Done"].tap()

        // set location
        app.buttons["Set Location"].tap()
        app.textFields["Zip Code"].tap()
        app.typeText("77429")
        app.buttons["SUBMIT"].tap()
        
        let tablesQuery = app.tables
    }
    
}
