//
//  ReportParsingTest.swift
//  FiveCallsTests
//
//  Created by Nick O'Neill on 12/20/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

final class ReportParsingTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
            let totalCallExpected = 3110741
            XCTAssert(getReport.numberOfCalls == totalCallExpected, "number of calls was \(getReport.numberOfCalls ?? 0), expected \(3110741)")
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
