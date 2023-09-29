//
//  AppState.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 7/24/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation
import CoreLocation
import os

class AppState: ObservableObject, ReduxState {
    @Published var issues: [Issue] = []
    @Published var contacts: [Contact] = []
    @Published var location: NewUserLocation? {
        didSet {
            guard let location = self.location else { return }
            let defaults = UserDefaults.standard
            defaults.set(location.locationType.rawValue, forKey: UserDefaultsKey.locationType.rawValue)
            defaults.set(location.locationValue, forKey: UserDefaultsKey.locationValue.rawValue)
            defaults.set(location.locationDisplay, forKey: UserDefaultsKey.locationDisplay.rawValue)
            Logger().info("saved cached location as \(location)")
        }
    }
    @Published var fetchingContacts = false
    @Published var issueLoadingError: Error? = nil
    @Published var contactsLoadingError: Error? = nil

    init() {
        // load user location cache
        if let locationType = UserDefaults.standard.string(forKey: UserDefaultsKey.locationType.rawValue),
            let locationValue = UserDefaults.standard.string(forKey: UserDefaultsKey.locationValue.rawValue) {
            let locationDisplay = UserDefaults.standard.string(forKey: UserDefaultsKey.locationDisplay.rawValue)
            Logger().info("loading cached location: \(locationType) \(locationValue) \(locationDisplay ?? "")")
            
            switch locationType {
            case "address", "zipCode":
                location = NewUserLocation(address: locationValue, display: locationDisplay)
            case "coordinates":
                let locValues = locationValue.split(separator: ",")
                if locValues.count != 2 { return }
                guard let lat = Double(locValues[0]), let lng = Double(locValues[1]) else { return }
                
                location = NewUserLocation(location: CLLocation(latitude: lat, longitude: lng), display: locationDisplay)
            default:
                Logger().warning("unknown stored location type data: \(locationType)")
            }
        }
    }
}
