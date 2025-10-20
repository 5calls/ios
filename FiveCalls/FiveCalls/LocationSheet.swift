// Copyright 5calls. All rights reserved. See LICENSE for details.

import CoreLocation
import SwiftUI

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
                if store.state.isSplitDistrict {
                    Text(
                        "\(Image(systemName: "exclamationmark.triangle")) \(String(localized: "This zip code is split between multiple Congressional districts, please use a zip+4 or address for best accuracy.", comment: "Split district location warning"))"
                    )
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal, 35)
                    .padding(.bottom, 10)
                }
                HStack {
                    HStack {
                        TextField(text: $locationText) {
                            Text("Enter a location", comment: "LocationSheet prompt")
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
                    .accessibilityLabel(
                        Text(
                            "Search my location",
                            comment: "LocationSheet search accessibility label"
                        )
                    )
                    .accessibilityAddTraits(.isButton)
                }
                Text("Use an address, zip code or zip + 4", comment: "LocationSheet instructions")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.leading, 35)
                    .accessibilityHidden(true)
            }
            .padding(.bottom)
            HStack(alignment: .top) {
                Text("Or", comment: "LocationSheet 'Or' text")
                    .font(.system(.title3))
                    .padding(.trailing)
                    .padding(.top, 10)
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Detect my location", comment: "LocationSheet 'Detect my location' text")
                                .font(.system(.title3))
                                .fontWeight(.medium)
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
            .accessibilityLabel(
                Text(
                    "Detect my location",
                    comment: "LocationSheet detect my location accessibility label"
                )
            )
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
                var locationDisplay = String(localized: "Unknown Location")
                let placemarks = try await CLGeocoder().geocodeAddressString(locationText)
                guard let placemark = placemarks.first else {
                    return
                }

                locationDisplay = placemark.locality ?? placemark.administrativeArea ?? placemark.postalCode ?? String(localized: "Unknown Location")
                let loc = UserLocation(address: locationText, display: locationDisplay)
                store.dispatch(action: .SetLocation(loc))
                dismiss()
            } catch (_) {
                locationError = String(
                    localized: "An error occured trying to find your location",
                    comment: "Default location error message"
                )
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
                let loc = UserLocation(location: clLoc, display: locationInfo["displayName"] as? String ?? String(localized: "Unknown Location"))
                store.dispatch(action: .SetLocation(loc))
                detectProcessing = false
                dismiss()
            } catch {
                if case LocationCoordinatorError.Unauthorized = error {
                    locationError = String(localized: "Location permission is off", comment: "Error message when location permission is off")
                } else {
                    locationError = String(
                        localized: "An error occured trying to find your location",
                    )
                }

                detectProcessing = false
            }
        }
    }

    func getLocationInfo(from location: CLLocation) async throws -> [String: Any] {
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

#Preview {
    let store = Store(state: AppState(), middlewares: [appMiddleware()])
    LocationSheet().environmentObject(store)

    LocationSheet(locationError: "A location error string").environmentObject(store)
}
