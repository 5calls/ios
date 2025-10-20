// Copyright 5calls. All rights reserved. See LICENSE for details.

import CoreLocation
import XCTest
@testable import FiveCalls

private let kLocation = CLLocation(latitude: 37.752193, longitude: -122.420668)

@MainActor
final class LocationSheetTests: XCTestCase {
    func testGetLocationInfo() async throws {
        let locationSheet = LocationSheet()
        let locationInfo = try await locationSheet.getLocationInfo(from: kLocation)
        XCTAssertEqual(locationInfo["longitude"] as! CLLocationDegrees, kLocation.coordinate.longitude)
        XCTAssertEqual(locationInfo["latitude"] as! CLLocationDegrees, kLocation.coordinate.latitude)
        XCTAssertEqual(locationInfo["displayName"] as! String, "San Francisco")
        XCTAssertEqual(locationInfo["zipcode"] as! String, "94110")
    }
}
