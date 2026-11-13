// Copyright 5calls. All rights reserved. See LICENSE for details.

import XCTest
@testable import FiveCalls

final class ContactParsingTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        UserDefaults.standard.set(Bundle(for: ContactParsingTest.self).path(forResource: "GET-v1-reps", ofType: "json"), forKey: "mock-GET:/v1/reps")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParseContacts() throws {
        let exp = expectation(description: "parsing contacts")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ProtocolMock.self]
        let fetchContacts = FetchContactsOperation(location: UserLocation(address: "3400 24th St, SF, CA"), config: config)
        fetchContacts.completionBlock = {
            if let error = fetchContacts.error {
                return XCTFail("contact request failed: \(error)")
            }
            guard let contacts = fetchContacts.contacts else { return XCTFail("no contacts present") }
            let contactCountExpected = 8
            XCTAssert(contacts.count == contactCountExpected, "found \(contacts.count) issues, expected \(contactCountExpected)")
            let contactNameExpected = "Gavin Newsom"
            XCTAssert(contacts[0].name == contactNameExpected, "first contact was \(contacts[0].name) not \(contactNameExpected)")
            let fieldOfficeExpected = "Fresno"
            XCTAssert(contacts[3].fieldOffices[0].city == fieldOfficeExpected, "field office was \(contacts[3].fieldOffices[0].city), not \(fieldOfficeExpected)")
            exp.fulfill()
        }
        OperationQueue.main.addOperation(fetchContacts)
        // TODO: as part of an operations refactor, await this return so this test finishes ~immediately
        waitForExpectations(timeout: 10) // I hate myself for doing this, but I just need this to be less fragile until the code gets refactored.
    }

    // MARK: rep notices

    private func decodeContactList(_ json: String) throws -> ContactList {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ContactList.self, from: Data(json.utf8))
    }

    private func repsJSON(notice: String?) -> String {
        let noticeField = notice.map { ", \"notice\": \($0)" } ?? ""
        return """
        {"location": "San Francisco", "lowAccuracy": false, "isSplit": false, "state": "CA",
         "district": "11", "representatives": []\(noticeField)}
        """
    }

    func testParsesRepNotice() throws {
        let list = try decodeContactList(repsJSON(notice: """
        {"id": 4, "text": " New members take office in January. ", "expiresAt": "2027-01-04T00:00:00Z"}
        """))

        let notice = try XCTUnwrap(list.notice)
        XCTAssertEqual(notice.id, 4)
        XCTAssertEqual(notice.text, "New members take office in January.")
        XCTAssertEqual(notice.expiresAt, Date(timeIntervalSince1970: 1_799_020_800))
    }

    func testNoRepNotice() throws {
        XCTAssertNil(try decodeContactList(repsJSON(notice: nil)).notice)
        XCTAssertNil(try decodeContactList(repsJSON(notice: "null")).notice)
    }

    func testMalformedRepNoticeKeepsReps() throws {
        // a bad notice must not fail the reps response
        let list = try decodeContactList(repsJSON(notice: "{\"text\": 12}"))
        XCTAssertNil(list.notice)
        XCTAssertEqual(list.state, "CA")
    }

    func testRepNoticeTimestampFormats() {
        let expected = Date(timeIntervalSince1970: 1_799_020_800)
        XCTAssertEqual(RepNotice.parseTimestamp("2027-01-04T00:00:00Z"), expected)
        XCTAssertEqual(RepNotice.parseTimestamp("2027-01-04T00:00:00.000Z"), expected)
        XCTAssertEqual(RepNotice.parseTimestamp("2027-01-03T16:00:00-08:00"), expected)
        XCTAssertNil(RepNotice.parseTimestamp("January 2027"))
    }

    func testRepNoticeIsActive() {
        let expiry = Date(timeIntervalSince1970: 1_799_020_800)
        let notice = RepNotice(id: 1, text: "Hello", expiresAt: expiry)
        XCTAssertTrue(notice.isActive(now: expiry.addingTimeInterval(-1)))
        // expiry is exclusive, matching the API
        XCTAssertFalse(notice.isActive(now: expiry))
        XCTAssertTrue(RepNotice(id: 1, text: "Hello", expiresAt: nil).isActive(now: .distantFuture))
        XCTAssertFalse(RepNotice(id: 1, text: "", expiresAt: nil).isActive())
    }
}
