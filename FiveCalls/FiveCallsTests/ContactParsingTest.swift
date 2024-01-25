//
//  ContactParsingTest.swift
//  FiveCallsTests
//
//  Created by Nick O'Neill on 12/20/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

final class ContactParsingTest: XCTestCase {

    override func setUpWithError() throws {        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UserDefaults.standard.set(Bundle(for: ContactParsingTest.self).path(forResource: "GET-v1-reps", ofType: "json"), forKey: "mock-GET:/v1/reps")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseContacts() throws {
        let exp = expectation(description: "parsing contacts")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ProtocolMock.self]
        let fetchContacts = FetchContactsOperation(location: UserLocation(address: "3400 24th St, SF, CA"), config: config)
        fetchContacts.completionBlock = {
            if let error = fetchContacts.error {
                return XCTFail("contact request failed: \(error)")
            }
            guard let contacts = fetchContacts.contacts else { return XCTFail("no contacts present") }
            let contactCountExpected = 8
            XCTAssert(contacts.count == contactCountExpected, "found \(contacts.count) issues, expected \(contactCountExpected)")
            let contactNameExpected = "Gavin Newsom"
            XCTAssert(contacts[0].name == contactNameExpected, "first contact was \(contacts[0].name) not \(contactNameExpected)")
            let fieldOfficeExpected = "Fresno"
            XCTAssert(contacts[3].fieldOffices[0].city == fieldOfficeExpected, "field office was \(contacts[3].fieldOffices[0].city), not \(fieldOfficeExpected)")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(fetchContacts)
        // TODO: as part of an operations refactor, await this return so this test finishes ~immediately
        waitForExpectations(timeout: 2)
    }
}
