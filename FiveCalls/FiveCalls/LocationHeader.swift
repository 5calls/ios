//
//  LocationHeader.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/4/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct LocationHeader: View {
    let location: UserLocation?
    let fetchingContacts: Bool
    
    var body: some View {
        HStack {
            Spacer()
            if fetchingContacts {
                SwiftUI.ProgressView()
            }
            if location == nil {
                unsetLocationView
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.quaternaryLabel))
                    }
            } else {
                locationView
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.quaternaryLabel))
                    }
            }
            Spacer()
        }
    }
    
    var locationView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Your location is:")
                    .font(.footnote)
                Text(location!.locationDisplay ?? "Unknown location")
                    .font(.system(.title3))
                    .fontWeight(.medium)
            }
            .padding(.leading)
            .padding(.vertical, 10)
            Image(systemName: "location.circle")
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .font(.title3)
                .padding(.trailing)
                .padding(.leading, 7)
        }
    }
    
    var unsetLocationView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Set your location")
                    .font(.system(.title3))
                    .fontWeight(.medium)
            }
            .padding(.leading)
            .padding(.vertical, 10)
            Image(systemName: "location.circle")
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .font(.title3)
                .padding(.trailing)
                .padding(.leading, 7)
        }
    }
}

struct LocationHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LocationHeader(location: nil, fetchingContacts: true)
            LocationHeader(location: UserLocation.current, fetchingContacts: false)
            Spacer()
        }.onAppear {
            UserLocation.current.setFrom(address: "19444")
        }
    }
}
