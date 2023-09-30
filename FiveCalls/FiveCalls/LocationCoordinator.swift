//
//  LocationCoordinator.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/7/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import Foundation
import CoreLocation
import os

enum LocationCoordinatorError: Error {
    case NoLocationsReturned
    case Unauthorized
    case LocationManagerError(Error)
}

class LocationCoordinator: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
        
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func getLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation({ continuation in
            locationContinuation = continuation
            DispatchQueue.global(qos: .userInitiated).async { [weak self] () -> Void in
                switch self?.manager.authorizationStatus {
                case .denied, .restricted:
                    self?.locationContinuation?.resume(throwing: LocationCoordinatorError.Unauthorized)
                case .authorizedAlways, .authorizedWhenInUse:
                    self?.manager.requestLocation()
                default:
                    self?.manager.requestWhenInUseAuthorization()
                }
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("new location: \(locations)")
        if let location = locations.first {
            locationContinuation?.resume(with: .success(location))
        } else {
            locationContinuation?.resume(with: .failure(LocationCoordinatorError.NoLocationsReturned))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("loc manager failed: \(error)")
        locationContinuation?.resume(with: .failure(error))
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        print("change authorization: \(manager.authorizationStatus)")
        if manager.authorizationStatus == .authorizedWhenInUse {
            DispatchQueue.global(qos: .userInitiated).async { () -> Void in
                manager.requestLocation()
            }
        } else if manager.authorizationStatus == .denied {
            locationContinuation?.resume(with: .failure(LocationCoordinatorError.Unauthorized))
        }
    }
}
