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

    func testSingleContactReplacement() throws {
        let contact = Contact()
        let script = "Hello [REP/SEN NAME], my name is a constituent"

        let replacedScript = try XCTUnwrap(contact.customizeScript(script: script))

        let expectedScript = "Hello Rep. Test Name, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testMultipleContactReplacement() throws {
        let contact = Contact()
        let script = "Hello [REP/SEN NAME], my name is a constituent and I would like [REP/SEN NAME] to do a thing"

        let replacedScript = try XCTUnwrap(contact.customizeScript(script: script))

        let expectedScript = "Hello Rep. Test Name, my name is a constituent and I would like Rep. Test Name to do a thing"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testLocationReplacement() throws {
        let location = UserLocation()
        location.locationDisplay = "San Francisco"
        let script = "Hello, my name is a constituent from [CITY, STATE]"

        let replacedScript = try XCTUnwrap(location.customizeScript(script: script))


        let expectedScript = "Hello, my name is a constituent from San Francisco"
        XCTAssertEqual(replacedScript, expectedScript)
    }
}
