import XCTest
@testable import FiveCalls

final class AppStateTests: XCTestCase {
    
    var sut: AppState!
    
    override func setUp() {
        super.setUp()
        sut = AppState()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testIssueCalledOn_WhenNoCompletions_ReturnsFalse() {
        let issueID = 123
        let contactID = "B0001234"
        
        let result = sut.issueCalledOn(issueID: issueID, contactID: contactID)
        
        XCTAssertFalse(result)
    }
    
    func testIssueCalledOn_WhenContactCalledForIssue_ReturnsTrue() {
        let issueID = 123
        let contactID = "B0001234"
        sut.issueCompletion = [issueID: ["\(contactID)-contacted"]]
        
        let result = sut.issueCalledOn(issueID: issueID, contactID: contactID)
        
        XCTAssertTrue(result)
    }
    
    func testIssueCalledOn_WhenDifferentContactCalledForIssue_ReturnsFalse() {
        let issueID = 123
        let contactID = "B0001234"
        sut.issueCompletion = [issueID: ["B0005678-contacted"]]
        
        let result = sut.issueCalledOn(issueID: issueID, contactID: contactID)
        
        XCTAssertFalse(result)
    }
    
    func testIssueCalledOn_WhenContactCalledForDifferentIssue_ReturnsFalse() {
        let issueID = 123
        let contactID = "B0001234"
        sut.issueCompletion = [456: ["\(contactID)-contacted"]]
        
        let result = sut.issueCalledOn(issueID: issueID, contactID: contactID)
        
        XCTAssertFalse(result)
    }
    
    func testIssueCalledOn_WithMultipleOutcomes_ReturnsTrue() {
        let issueID = 123
        let contactID = "B0001234"
        sut.issueCompletion = [issueID: ["B0005678-contacted", "\(contactID)-unavailable"]]
        
        let result = sut.issueCalledOn(issueID: issueID, contactID: contactID)
        
        XCTAssertTrue(result)
    }

    func testIssueCalledOn_WithHyphenatedContactID_ReturnsTrue() {
        let issueID = 123
        let contactID = "ca-newsom"
        sut.issueCompletion = [issueID: ["\(contactID)-contacted"]]
        
        let result = sut.issueCalledOn(issueID: issueID, contactID: contactID)
        
        XCTAssertTrue(result)
    }
} 
