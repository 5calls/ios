//
//  IssueParsingTest.swift
//  FiveCallsTests
//
//  Created by Nick O'Neill on 12/19/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

final class IssueParsingTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseIssues() throws {
        let exp = expectation(description: "parsing issues")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ProtocolMock.self]
        let fetchIssues = FetchIssuesOperation(config: config)
        fetchIssues.completionBlock = {
            guard let issues = fetchIssues.issuesList else { return XCTFail("no issues present") }
            XCTAssert(issues.count == 60, "found \(issues.count) issues, expected 60")
            XCTAssert(issues[0].id == 664, "first issue was not id 664 as expected")
            XCTAssert(issues[11].createdAt.timeIntervalSince1970 == 1565582054, "12th issue did not have created date as expected")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(fetchIssues)
        waitForExpectations(timeout: 2)
    }
}
