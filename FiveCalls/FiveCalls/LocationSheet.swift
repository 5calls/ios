//
//  LocationSheet.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/7/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import CoreLocation

struct LocationSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var store: Store
    
    @State var locationText: String = ""
    @State var locationError: String?
    @State var detectProcessing = false

    let locationCoordinator = LocationCoordinator()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack {
                        TextField(text: $locationText) {
                            Text(R.string.localizable.enterLocation())
                        }.onSubmit {
                            locationSearch()
                        }
                        .padding(.leading)
                        .accessibilityIdentifier("locationField")
                    }
                    .padding(.vertical, 12)
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(Color(.tertiarySystemFill))
                    }
                    .padding(.leading, 24)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.blue)
                            .frame(width: 46, height: 46)
                            .clipped()
                        Image(systemName: "location.magnifyingglass")
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                    .onTapGesture {
                        locationSearch()
                    }
                    .accessibilityHidden(true)
                }
                Text(R.string.localizable.locationInstructions())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.leading, 35)
                    .accessibilityHidden(true)
            }
            .padding(.bottom)
            HStack(alignment: .top) {
                Text(R.string.localizable.locationOr())
                    .font(.system(.title3))
                    .padding(.trailing)
                    .padding(.top, 10)
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(R.string.localizable.detectLocation())
                                .font(.system(.title3))
                                .fontWeight( .medium)
                                .foregroundColor(.white)
                        }
                        .padding(.leading)
                        .padding(.vertical, 10)
                        ZStack {
                            Image(systemName: "location.circle")
                                .imageScale(.large)
                                .symbolRenderingMode(.hierarchical)
                                .font(.title3)
                                .padding(.trailing)
                                .padding(.leading, 7)
                                .foregroundColor(.white)
                                .opacity(detectProcessing ? 0 : 1)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing)
                                .padding(.leading, 7)
                                .opacity(detectProcessing ? 1 : 0)
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.blue)
                            .opacity(detectProcessing ? 0.5 : 1)
                    }
                    .onTapGesture {
                        if !detectProcessing {
                            detectLocation()
                        }
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(R.string.localizable.detectLocation()))
            .accessibilityAddTraits(.isButton)
            
            if locationError != nil {
                Text(locationError!)
                    .font(.caption)
                    .foregroundColor(.red)

            }
        }
    }
    
    func locationSearch() {
        locationError = nil

        Task {
            do {
                var locationDisplay = R.string.localizable.unknownLocation()
                let placemarks = try await CLGeocoder().geocodeAddressString(locationText)
                guard let placemark = placemarks.first else {
                    return
                }

                locationDisplay = placemark.locality ?? placemark.administrativeArea ?? placemark.postalCode ?? R.string.localizable.unknownLocation()
                let loc = UserLocation(address: locationText, display: locationDisplay)
                store.dispatch(action: .SetLocation(loc))
                dismiss()
            } catch (let error) {
                locationError = R.string.localizable.locationErrorDefault()
            }
        }
    }
    
    func detectLocation() {
        detectProcessing = true
        locationError = nil
        
        Task {
            do {
                let clLoc = try await locationCoordinator.getLocation()
                let locationInfo = try await getLocationInfo(from: clLoc)
                let loc = UserLocation(location: clLoc, display: locationInfo["displayName"] as? String ?? R.string.localizable.unknownLocation())
                store.dispatch(action: .SetLocation(loc))
                detectProcessing = false
                dismiss()
            } catch (let error) {
                if case LocationCoordinatorError.Unauthorized = error {
                    locationError = R.string.localizable.locationErrorOff()
                } else {
                    locationError = R.string.localizable.locationErrorDefault()
                }

                detectProcessing = false
            }
        }
    }

    private func getLocationInfo(from location: CLLocation) async throws -> [String: Any] {
        var locationInfo = [String: Any]()
        locationInfo["longitude"] = location.coordinate.longitude
        locationInfo["latitude"] = location.coordinate.latitude
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        let prefix = placemarks.first?.subThoroughfare ?? ""
        let street = placemarks.first?.thoroughfare ?? ""
        let streetAddress = prefix + " " + street
        // prefer locality (generally the city name) but can fall back to address if needed
        locationInfo["displayName"] = placemarks.first?.locality ?? (streetAddress != " " ? streetAddress : nil) ?? nil
        locationInfo["zipcode"] = placemarks.first?.postalCode ?? ""
        return locationInfo
    }
}

struct LocationSheet_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(state: AppState(), middlewares: [appMiddleware()])
        LocationSheet().environmentObject(store)
        LocationSheet(locationError: "A location error string").environmentObject(store)
    }
}
