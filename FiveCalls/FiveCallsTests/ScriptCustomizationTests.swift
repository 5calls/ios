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
        let script = "Hello [REP/SEN NAME], my name is a constituent"

        let replacedScript = ScriptReplacements.replacingContact(script: script, contact: Contact.housePreviewContact)

        let expectedScript = "Hello Rep. Housy McHouseface, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testMultipleContactReplacement() throws {
        let script = "Hello [REP/SEN NAME], my name is a constituent and I would like [REP/SEN NAME] to do a thing"

        let replacedScript = ScriptReplacements.replacingContact(script: script, contact: Contact.housePreviewContact)

        let expectedScript = "Hello Rep. Housy McHouseface, my name is a constituent and I would like Rep. Housy McHouseface to do a thing"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testLocationReplacement() throws {
        let location = NewUserLocation(address: "123 Main St", display: "San Francisco")
        let script = "Hello, my name is a constituent from [CITY, STATE]"

        let replacedScript = ScriptReplacements.replacingLocation(script: script, location: location)

        let expectedScript = "Hello, my name is a constituent from San Francisco"
        XCTAssertEqual(replacedScript, expectedScript)
    }
}
