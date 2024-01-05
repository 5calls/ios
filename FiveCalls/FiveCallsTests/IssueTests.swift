//
//  IssueTests.swift
//  FiveCallsTests
//
//  Created by Nick O'Neill on 1/4/24.
//  Copyright © 2024 5calls. All rights reserved.
//

import XCTest
@testable import FiveCalls

final class IssueTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidIssue() throws {
        // intentionally misformatting a slug value here
        let issue = Issue(id: 813, meta: "", name: "Support the Act", slug: "support-act-slug ", reason: Issue.issueReason, script: Issue.issueScript, categories: [Category(name: "Budget")], active: true, outcomeModels: [Outcome(label: "Contacted", status: "contact"), Outcome(label: "Voicemail", status: "voicemail")], contactType: "reps", contactAreas: ["US House", "US Senate"], createdAt: Date(timeIntervalSince1970: 1688015904))
        
        let expectedShareURL = URL(string: "https://5calls.org/issue/support-act-slug/")!
        let expectedShareImageURL = URL(string: "https://api.5calls.org/v1/issue/813/share/t")!
        XCTAssert(issue.shareURL == expectedShareURL, "share url was \(issue.shareURL), expected \(expectedShareURL)")
    }
}
