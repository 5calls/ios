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
    static let current = UserLocation()
    
    var defaults: UserDefaults = .standard
    var locationType: LocationType?
    
    enum LocationType: String {
        case zipCode
        case coordinates
    }
    
    var locationValue: String?
    var locationDisplay: String?
    
    func setFrom(zipCode: String) {
        locationType = .zipCode
        locationValue = zipCode
        locationDisplay = zipCode
        locationChanged()
    }
    
    func setFrom(location: CLLocation, completion: @escaping (Void) -> Void) {
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
            locationInfo["displayName"] = streetAddress != " " ? streetAddress : nil
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
