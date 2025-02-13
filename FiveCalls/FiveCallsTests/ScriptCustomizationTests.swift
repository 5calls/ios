//
//  ScriptCustomizationTests.swift
//  FiveCallsTests
//
//  Created by Nick O'Neill on 5/3/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

private let kLocation = UserLocation(address: "123 Main St", display: "San Francisco")


class ScriptCustomizationTests: XCTestCase {

    func testSingleContactReplacement() throws {
        let script = "Hello [REP/SEN NAME], my name is a constituent"

        let replacedScript = ScriptReplacements.replacingContact(script: script, contact: Contact.housePreviewContact)

        let expectedScript = "Hello Rep. Housy McHouseface, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }
    
    func testAlternateHouseContactReplacement() throws {
        let script = "Hello [REPRESENTATIVE NAME], my name is a constituent"

        let replacedScript = ScriptReplacements.replacingContact(script: script, contact: Contact.housePreviewContact)

        let expectedScript = "Hello Rep. Housy McHouseface, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }
    
    func testAlternateSenateContactReplacement() throws {
        let script = "Hello [SENATOR NAME], my name is a constituent"

        let replacedScript = ScriptReplacements.replacingContact(script: script, contact: Contact.senatePreviewContact1)

        let expectedScript = "Hello Senator Senatey McDefinitelyOld, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testMultipleContactReplacement() throws {
        let script = "Hello [REP/SEN NAME], my name is a constituent and I would like [REP/SEN NAME] to do a thing"

        let replacedScript = ScriptReplacements.replacingContact(script: script, contact: Contact.housePreviewContact)

        let expectedScript = "Hello Rep. Housy McHouseface, my name is a constituent and I would like Rep. Housy McHouseface to do a thing"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testLocationReplacement() throws {
        let script = "Hello, my name is a constituent from [CITY, STATE]"

        let replacedScript = ScriptReplacements.replacingLocation(script: script, location: kLocation)

        let expectedScript = "Hello, my name is a constituent from San Francisco"
        XCTAssertEqual(replacedScript, expectedScript)
    }
    
    func testUnknownAreaContactReplacement() throws {
        let script = "Hello [REP/SEN NAME], my name is a constituent"

        let replacedScript = ScriptReplacements.replacingContact(script: script, contact: Contact.unknownMayorPreviewContact)

        let expectedScript = "Hello Mayor McMayorface, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }
    
    func testChooseHouseSubscript() throws {
        let script = "Hello!\n\n**WHEN CALLING HOUSE:**\nI'm calling to urge **[REPRESENTATIVE NAME]** to support house bill.\n\n**WHEN CALLING SENATE:**\nI'm calling to urge **[SENATOR NAME]** to support senate bill.\n\nThank you for your time and consideration."

        let replacedScript = ScriptReplacements.chooseSubscript(script: script, contact: Contact.housePreviewContact)

        let expectedScript = "Hello!\n\nI'm calling to urge **[REPRESENTATIVE NAME]** to support house bill.\n\nThank you for your time and consideration."
        XCTAssertEqual(replacedScript, expectedScript)
    }
    
    func testChooseSenateSubscript() throws {
        let script = "Hello!\n\n**WHEN CALLING HOUSE:**\nI'm calling to urge **[REPRESENTATIVE NAME]** to support house bill.\n\n**WHEN CALLING SENATE:**\nI'm calling to urge **[SENATOR NAME]** to support senate bill.\n\nThank you for your time and consideration."

        let replacedScript = ScriptReplacements.chooseSubscript(script: script, contact: Contact.senatePreviewContact1)

        let expectedScript = "Hello!\n\nI'm calling to urge **[SENATOR NAME]** to support senate bill.\n\nThank you for your time and consideration."
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testChooseUnknownAreaSubscript() throws {
        let script = "Hello!\n\n**WHEN CALLING HOUSE:**\nI'm calling to urge **[REPRESENTATIVE NAME]** to support house bill.\n\n**WHEN CALLING SENATE:**\nI'm calling to urge **[SENATOR NAME]** to support senate bill.\n\nThank you for your time and consideration."

        let replacedScript = ScriptReplacements.chooseSubscript(script: script, contact: Contact.unknownMayorPreviewContact)

        let expectedScript = "Hello!\n\n**WHEN CALLING HOUSE:**\nI'm calling to urge **[REPRESENTATIVE NAME]** to support house bill.\n\n**WHEN CALLING SENATE:**\nI'm calling to urge **[SENATOR NAME]** to support senate bill.\n\nThank you for your time and consideration."
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testChooseSubscriptStripsNothingWithoutIntro() throws {
        let script = "Hello!\n\nI'm calling to urge **[REP/SEN NAME]** to support a bill.\n\nThank you for your time and consideration."

        let replacedScript = ScriptReplacements.chooseSubscript(script: script, contact: Contact.housePreviewContact)

        let expectedScript = "Hello!\n\nI'm calling to urge **[REP/SEN NAME]** to support a bill.\n\nThank you for your time and consideration."
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testNoReplacement() throws {
        let script = "Hello, my name is a constituent"

        let replacedScript = ScriptReplacements.replacing(script: script, contact: Contact.housePreviewContact, location: kLocation)

        let expectedScript = "Hello, my name is a constituent"
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testMultipleHouseSubscriptSections() throws {
        let script = """
            Hello!
            
            **WHEN CALLING HOUSE:**
            First house section with **[REPRESENTATIVE NAME]**
            
            Some middle text.
            
            **WHEN CALLING HOUSE:**
            Second house section
            
            **WHEN CALLING SENATE:**
            Senate section should be removed
            
            Thank you for your time.
            """

        let replacedScript = ScriptReplacements.chooseSubscript(script: script, contact: Contact.housePreviewContact)

        let expectedScript = """
            Hello!
            
            First house section with **[REPRESENTATIVE NAME]**
            
            Some middle text.
            
            Second house section
            
            Thank you for your time.
            """
        XCTAssertEqual(replacedScript, expectedScript)
    }

    func testMultipleSenateSubscriptSections() throws {
        let script = """
            Hello!
            
            **WHEN CALLING SENATE:**
            First senate section with **[SENATOR NAME]**
            
            Some middle text.
            
            **WHEN CALLING HOUSE:**
            House section should be removed
            
            **WHEN CALLING SENATE:**
            Second senate section
            
            Thank you for your time.
            """

        let replacedScript = ScriptReplacements.chooseSubscript(script: script, contact: Contact.senatePreviewContact1)

        let expectedScript = """
            Hello!
            
            First senate section with **[SENATOR NAME]**
            
            Some middle text.
            
            Second senate section
            
            Thank you for your time.
            """
        XCTAssertEqual(replacedScript, expectedScript)
    }
}
