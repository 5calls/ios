//
//  NewUserLocation.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/9/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation
import CoreLocation

// NewUserLocation is like UserLocation from the old app but it doesn't need a singleton to maintain its state
class NewUserLocation {
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
    
    init(address: String, display: String? = nil, gotDisplay: ((NewUserLocation) -> Void)? = nil) {
        locationType = .address
        locationValue = address
        
        // we can cache the display name when we've already fetched it, otherwise we'll go get it
        if let display {
            locationDisplay = display
            gotDisplay?(self)
            return
        }
        locationDisplay = "Locating..."
        
        CLGeocoder().geocodeAddressString(address) { results, error in
            guard let placemark = results?.first else {
                self.locationDisplay = "Unknown location"
                gotDisplay?(self)
                return
            }
            
            self.locationDisplay = placemark.locality ?? placemark.administrativeArea ?? placemark.postalCode ?? "Unknown location"
            gotDisplay?(self)
        }
    }
    
    init(location: CLLocation, display: String? = nil, gotDisplay: ((NewUserLocation) -> Void)? = nil) {
        locationType = .coordinates
        locationValue = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        locationDisplay = "..."
        
        if let display {
            locationDisplay = display
            gotDisplay?(self)
            return
        }
        
        getLocationInfo(from: location) { locationInfo in
            self.locationDisplay = locationInfo["displayName"] as? String ?? "Unknown location"
            gotDisplay?(self)
        }
    }
    
    private func getLocationInfo(from location: CLLocation, completion: @escaping (([String: Any]) -> ())) {
        var locationInfo = [String: Any]()
        locationInfo["longitude"] = location.coordinate.longitude
        locationInfo["latitude"] = location.coordinate.latitude
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            let prefix = placemarks?.first?.subThoroughfare ?? ""
            let street = placemarks?.first?.thoroughfare ?? ""
            let streetAddress = prefix + " " + street
            // prefer locality (generally the city name) but can fall back to address if needed
            locationInfo["displayName"] = placemarks?.first?.locality ?? (streetAddress != " " ? streetAddress : nil) ?? nil
            locationInfo["zipcode"] = placemarks?.first?.postalCode ?? ""
            completion(locationInfo)
        })
    }
}

extension NewUserLocation : CustomStringConvertible {
    var description: String {
        return "type: \(locationType.rawValue) value: \(locationValue) | display: \(locationDisplay)"
    }
}

//extension UserLocation {
//    func customizeScript(script: String) -> String? {
//        guard let locationDisplay = self.locationDisplay else {
//            return nil
//        }
//
//        let pattern = #"\[CITY,\s?ZIP\]|\[CITY,\s?STATE\]"#
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
//            return nil
//        }
//
//        let fullRange = NSRange(script.startIndex..<script.endIndex, in: script)
//        let scriptWithLocation = regex.stringByReplacingMatches(in: script, options: [], range: fullRange, withTemplate: locationDisplay)
//        return scriptWithLocation
//    }
//}
