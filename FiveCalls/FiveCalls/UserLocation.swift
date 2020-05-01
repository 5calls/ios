//
//  UserLocation.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import CoreLocation

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
    
    static let current = UserLocation()
    
    var defaults: UserDefaults = .standard
    var locationType: LocationType? {
        get {
            guard let typeString = defaults.string(forKey: UserDefaultsKey.locationType.rawValue)
                else {
                    return nil
                }
            return LocationType(rawValue: typeString)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: UserDefaultsKey.locationType.rawValue)
        }
    }
    
    var locationValue: String? {
        get {
            return defaults.string(forKey: UserDefaultsKey.locationValue.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaultsKey.locationValue.rawValue)
        }
    }
    
    var locationDisplay: String? {
        get {
            return defaults.string(forKey: UserDefaultsKey.locationDisplay.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaultsKey.locationDisplay.rawValue)
        }
    }
    
    private static let geocoder = CLGeocoder()
    
    func setFrom(address: String, completion: ((UserLocation) -> Void)? = nil) {
        locationType = .address
        locationValue = address
        
        UserLocation.geocoder.geocodeAddressString(address) { results, error in
            defer {
                self.locationChanged()
                completion?(self)
            }
            
            guard let placemark = results?.first else {
                self.locationDisplay = R.string.localizable.fallbackUserLocationDesc()
                return
            }
            
            self.locationDisplay = placemark.locality ?? placemark.administrativeArea ?? placemark.postalCode
        }
    }
    
    func setFrom(location: CLLocation, completion: @escaping () -> Void) {
        locationType = .coordinates
        locationValue = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        locationDisplay = "..."
        getLocationInfo(from: location) { locationInfo in
            self.locationDisplay = locationInfo["displayName"] as? String
            self.locationChanged()
            completion()
        }
    }
    
    func locationChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .locationChanged, object: self)
        }
    }
    
    private func getLocationInfo(from location: CLLocation, completion: @escaping (([String: Any]) -> ())) {
        let geocoder = CLGeocoder()
        var locationInfo = [String: Any]()
        locationInfo["longitude"] = location.coordinate.longitude
        locationInfo["latitude"] = location.coordinate.latitude
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
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

extension UserLocation : CustomStringConvertible {
    var description: String {
        let typeString = locationType?.rawValue ?? ""
        let valueString = locationValue ?? ""
        let displayString = locationDisplay ?? ""
        return "type: \(typeString) value: \(valueString) | display: \(displayString)"
    }
}

extension UserLocation {
    func customizeScript(script: String) -> String? {
        guard let locationDisplay = self.locationDisplay else {
            return nil
        }

        let pattern = #"\[CITY,\s?ZIP\]|\[CITY,\s?STATE\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        let fullRange = NSRange(script.startIndex..<script.endIndex, in: script)
        let scriptWithLocation = regex.stringByReplacingMatches(in: script, options: [], range: fullRange, withTemplate: locationDisplay)
        return scriptWithLocation
    }
}
