// Copyright 5calls. All rights reserved. See LICENSE for details.

import XCTest
@testable import FiveCalls

final class IssueParsingTest: XCTestCase {
    override func setUpWithError() throws {
        UserDefaults.standard.set(Bundle(for: IssueParsingTest.self).path(forResource: "GET-v1-issues", ofType: "json"), forKey: "mock-GET:/v1/issues")
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
            let issueCountExpected = 60
            XCTAssert(issues.count == issueCountExpected, "found \(issues.count) issues, expected \(issueCountExpected)")
            let issueIDExpected = 664
            XCTAssert(issues[0].id == issueIDExpected, "first issue was not id \(issueIDExpected) as expected")
            let issueCreatedAtExpected: Double = 1_565_582_054
            XCTAssert(issues[11].createdAt.timeIntervalSince1970 == issueCreatedAtExpected, "12th issue did not have created date as expected")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(fetchIssues)
        // TODO: as part of an operations refactor, await this return so this test finishes ~immediately
        waitForExpectations(timeout: 2)
    }
}
