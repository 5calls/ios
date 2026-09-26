// Copyright 5calls. All rights reserved. See LICENSE for details.

import XCTest
@testable import FiveCalls

final class PostReferralTests: XCTestCase {
    func testLinkWithRef() throws {
        let operation = try XCTUnwrap(PostReferralOperation.forLink(URL(string: "https://5calls.org/issue/some-issue/?ref=newsletter")!))
        XCTAssertEqual(operation.ref, "newsletter")
        XCTAssertEqual(operation.path, "/issue/some-issue")
    }

    func testLinkWithoutRef() {
        XCTAssertNil(PostReferralOperation.forLink(URL(string: "https://5calls.org/issue/some-issue/")!))
        XCTAssertNil(PostReferralOperation.forLink(URL(string: "https://5calls.org/issue/some-issue/?utm_source=x")!))
    }

    func testLinkWithEmptyRef() {
        XCTAssertNil(PostReferralOperation.forLink(URL(string: "https://5calls.org/issue/some-issue/?ref=")!))
    }
}
