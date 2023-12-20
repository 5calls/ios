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
            XCTAssert(getReport.numberOfCalls == 3110741, "number of calls was \(getReport.numberOfCalls ?? 0), expected 3110741")
            XCTAssert(getReport.numberOfIssueCalls == 98673, "number of issue calls was \(getReport.numberOfIssueCalls ?? 0), expected 98673")
            XCTAssert(getReport.donateOn == true, "expected donateOn to be true")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(getReport)
        waitForExpectations(timeout: 2)
    }
}
