// Copyright 5calls. All rights reserved. See LICENSE for details.

import XCTest
@testable import FiveCalls

final class CustomizedScriptsTests: XCTestCase {
    override func setUpWithError() throws {
        UserDefaults.standard.set(
            Bundle(for: CustomizedScriptsTests.self).path(forResource: "GET-v1-issue-script", ofType: "json"),
            forKey: "mock-GET:/v1/issue/845/script"
        )
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: "mock-GET:/v1/issue/845/script")
    }

    func testFetchCustomizedScripts() throws {
        let exp = expectation(description: "fetching customized scripts")

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ProtocolMock.self]

        let operation = FetchCustomizedScriptsOperation(
            issueID: 845,
            contactIDs: ["C001126", "S001150"],
            location: "Home",
            callerName: "Nick",
            config: config
        )

        operation.completionBlock = {
            if let error = operation.error {
                return XCTFail("customized scripts request failed: \(error)")
            }

            guard let scripts = operation.scripts else {
                return XCTFail("no scripts present")
            }

            XCTAssertEqual(scripts.count, 2, "Expected 2 scripts")

            let repScript = scripts.first { $0.id == "C001126" }
            XCTAssertNotNil(repScript, "Rep script should exist")
            XCTAssertTrue(repScript!.script.contains("Rep. Carey"), "Should contain rep name")

            let senateScript = scripts.first { $0.id == "S001150" }
            XCTAssertNotNil(senateScript, "Senate script should exist")
            XCTAssertTrue(senateScript!.script.contains("Senator Schiff"), "Should contain senator name")

            exp.fulfill()
        }

        OperationQueue.main.addOperation(operation)
        waitForExpectations(timeout: 2)
    }
}
