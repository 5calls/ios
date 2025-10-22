// Copyright 5calls. All rights reserved. See LICENSE for details.

import CoreLocation
import XCTest
@testable import FiveCalls

final class UserLocationTests: XCTestCase {
    func testLocationTypeInitialization() {
        // Test case for "address" raw value
        if let locationType = UserLocation.LocationType(rawValue: "address") {
            XCTAssertEqual(locationType, .address)
        } else {
            XCTFail("Failed to initialize LocationType with raw value 'address'")
        }

        // Test case for "zipCode" raw value
        if let locationType = UserLocation.LocationType(rawValue: "zipCode") {
            XCTAssertEqual(locationType, .address)
        } else {
            XCTFail("Failed to initialize LocationType with raw value 'zipCode'")
        }

        // Test case for "coordinates" raw value
        if let locationType = UserLocation.LocationType(rawValue: "coordinates") {
            XCTAssertEqual(locationType, .coordinates)
        } else {
            XCTFail("Failed to initialize LocationType with raw value 'coordinates'")
        }

        // Test case for unknown raw value
        let unknownRawValue = "unknown"
        XCTAssertNil(UserLocation.LocationType(rawValue: unknownRawValue), "Expected nil for unknown raw value '\(unknownRawValue)'")
    }

    func testAddressLocationNoDisplay() throws {
        let userLocation = UserLocation(address: "123 Main St")
        XCTAssertEqual(userLocation.locationType, .address)
        XCTAssertEqual(userLocation.locationValue, "123 Main St")
        XCTAssertEqual(userLocation.locationDisplay, "Locating...")
    }

    func testAddressLocationWithDisplay() throws {
        let userLocation = UserLocation(address: "123 Main St", display: "123 Main St")
        XCTAssertEqual(userLocation.locationType, .address)
        XCTAssertEqual(userLocation.locationValue, "123 Main St")
        XCTAssertEqual(userLocation.locationDisplay, "123 Main St")
    }

    func testCoordinatesLocationNoDisplay() throws {
        let userLocation = UserLocation(location: CLLocation(latitude: 37.33233141, longitude: -122.0312186))
        XCTAssertEqual(userLocation.locationType, .coordinates)
        XCTAssertEqual(userLocation.locationValue, "37.33233141,-122.0312186")
        XCTAssertEqual(userLocation.locationDisplay, "...")
    }

    func testCoordinatesLocationWithDisplay() throws {
        let userLocation = UserLocation(location: CLLocation(latitude: 37.33233141, longitude: -122.0312186), display: "Cupertino, CA")
        XCTAssertEqual(userLocation.locationType, .coordinates)
        XCTAssertEqual(userLocation.locationValue, "37.33233141,-122.0312186")
        XCTAssertEqual(userLocation.locationDisplay, "Cupertino, CA")
    }
}
