//
//  ScriptCustomizationTests.swift
//  FiveCallsTests
//
//  Created by Nick O'Neill on 5/3/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

class ScriptCustomizationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSingleContactReplacement() {
        let contact = Contact()
        let script = "Hello [REP/SEN NAME], my name is a constituent"

        guard let replacedScript = contact.customizeScript(script: script) else {
            XCTFail("returned nil from script replacement")
            return
        }

        let expectedScript = "Hello Rep. Test Name, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testMultipleContactReplacement() {
        let contact = Contact()
        let script = "Hello [REP/SEN NAME], my name is a constituent and I would like [REP/SEN NAME] to do a thing"

        guard let replacedScript = contact.customizeScript(script: script) else {
            XCTFail("returned nil from script replacement")
            return
        }

        let expectedScript = "Hello Rep. Test Name, my name is a constituent and I would like Rep. Test Name to do a thing"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testLocationReplacement() {
        let location = UserLocation()
        location.locationDisplay = "San Francisco"

        let script = "Hello, my name is a constituent from [CITY, STATE]"

        guard let replacedScript = location.customizeScript(script: script) else {
            XCTFail("returned nil from script replacement")
            return
        }

        let expectedScript = "Hello, my name is a constituent from San Francisco"
        XCTAssertEqual(replacedScript, expectedScript)
    }
}
