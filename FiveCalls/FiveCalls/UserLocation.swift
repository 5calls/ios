//
//  UserLocation.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/9/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation
import CoreLocation
import RswiftResources

class UserLocation {
    enum LocationType: String {
        case address
        case coordinates
        
        init?(rawValue: String) {
            switch rawValue {
            //handle legacy persisted zipCodes as addresses
            case "address", "zipCode":
                self = .address
            case "coordinates":
                self = .coordinates
            default:
                return nil
            }
        }
    }
        
    var locationType: LocationType
    var locationValue: String
    var locationDisplay: String
    
    init(address: String, display: String? = nil) {
        locationType = .address
        locationValue = address
        locationDisplay = display ?? R.string.localizableR.locatingTemp()
    }
    
    init(location: CLLocation, display: String? = nil) {
        locationType = .coordinates
        locationValue = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        locationDisplay = display ?? "..."
    }
}

extension UserLocation: CustomStringConvertible {
    var description: String {
        return "type: \(locationType.rawValue) value: \(locationValue) | display: \(locationDisplay)"
    }
}

extension UserLocation: Equatable {
    static func == (lhs: UserLocation, rhs: UserLocation) -> Bool {
        return lhs.locationType == rhs.locationType
            && lhs.locationValue == rhs.locationValue
            && lhs.locationDisplay == rhs.locationDisplay
    }
}
