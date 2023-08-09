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
    
    let location: UserLocation?
    let delegate: AppStateDelegate?
    
    @State var locationText: String = ""
    @State var locationError: String?
    
    let locationCoordinator = LocationCoordinator()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack {
                        TextField(text: $locationText) {
                            Text("Enter a location")
                        }.onSubmit {
                            locationSearch()
                        }
                        .padding(.leading)
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
                }
                Text("Use an address, zip code or zip + 4")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.leading, 35)
            }
            .padding(.bottom)
            HStack(alignment: .top) {
                Text("Or")
                    .font(.system(.title3, weight: .regular))
                    .padding(.trailing)
                    .padding(.top, 10)
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Detect my location")
                                .font(.system(.title3, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.leading)
                        .padding(.vertical, 10)
                        Image(systemName: "location.circle")
                            .imageScale(.large)
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                            .padding(.trailing)
                            .padding(.leading, 7)
                            .foregroundColor(.white)
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.blue)
                    }
                    .onTapGesture {
                        detectLocation()
                    }
                    if locationError != nil {
                        Text(locationError!)
                            .font(.caption)
                            .foregroundColor(.red)
                            
                    }
                }
            }
        }
    }
    
    func locationSearch() {
        UserLocation.current.setFrom(address: locationText) { updatedLocation in
            delegate?.setLocation(location: updatedLocation)
            dismiss()
        }
    }
    
    func detectLocation() {
        locationError = nil
        
        Task {
            do {
                let loc = try await locationCoordinator.getLocation()
                UserLocation.current.setFrom(location: loc) {
                    delegate?.setLocation(location: UserLocation.current)
                }
                dismiss()
            } catch (let error as LocationCoordinatorError) {
                switch error {
                case .Unauthorized:
                    locationError = "Location permission is off"
                default:
                    locationError = "An error occured trying to find your location"
                }
            }
        }
    }
}

struct LocationSheet_Previews: PreviewProvider {
    static var previews: some View {
        LocationSheet(location: nil, delegate: nil)
        LocationSheet(location: nil, delegate: nil, locationError: "A location error string")
    }
}
