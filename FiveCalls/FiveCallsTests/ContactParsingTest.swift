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
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseContacts() throws {
        let exp = expectation(description: "parsing contacts")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ProtocolMock.self]
        let fetchContacts = FetchContactsOperation(location: NewUserLocation(address: "3400 24th St, SF, CA"), config: config)
        fetchContacts.completionBlock = {
            guard let contacts = fetchContacts.contacts else { return XCTFail("no contacts present") }
            XCTAssert(contacts.count == 8, "found \(contacts.count) issues, expected 8")
            XCTAssert(contacts[0].name == "Gavin Newsom", "first contact was \(contacts[0].name) not Gavin Newsome")
            XCTAssert(contacts[3].fieldOffices[0].city == "Fresno", "field office was \(contacts[3].fieldOffices[0].city), not Fresno")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(fetchContacts)
        waitForExpectations(timeout: 2)
    }
}
