// Copyright 5calls. All rights reserved. See LICENSE for details.

import XCTest
@testable import FiveCalls

final class ReportParsingTest: XCTestCase {
    override func setUpWithError() throws {
        UserDefaults.standard.set(Bundle(for: ContactParsingTest.self).path(forResource: "GET-v1-report", ofType: "json"), forKey: "mock-GET:/v1/report")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParsingReport() throws {
        let exp = expectation(description: "parsing report")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ProtocolMock.self]

        let getReport = FetchStatsOperation(config: config)
        getReport.completionBlock = {
            let totalCallExpected = 3_110_741
            XCTAssert(getReport.numberOfCalls == totalCallExpected, "number of calls was \(getReport.numberOfCalls ?? 0), expected \(3_110_741)")
            let issueCallExpected = 98673
            XCTAssert(getReport.numberOfIssueCalls == issueCallExpected, "number of issue calls was \(getReport.numberOfIssueCalls ?? 0), expected \(issueCallExpected)")
            let donateOnExpected = true
            XCTAssert(getReport.donateOn == donateOnExpected, "expected donateOn to be \(donateOnExpected)")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(getReport)
        // TODO: as part of an operations refactor, await this return so this test finishes ~immediately
        waitForExpectations(timeout: 2)
    }
}
