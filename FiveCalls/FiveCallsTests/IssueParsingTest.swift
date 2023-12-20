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
            XCTAssert(issues.count == 4, "found \(issues.count) issues, expected 4")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(fetchIssues)
        waitForExpectations(timeout: 2)
    }
}
