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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func usingRegularFonts() -> Bool {
        dynamicTypeSize < DynamicTypeSize.accessibility3
    }

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
                Text(R.string.localizable.yourLocationIs)
                    .font(.footnote)
                Text(location!.locationDisplay)
                    .font(.system(.title3))
                    .fontWeight(.medium)
            }
            .padding(.horizontal, usingRegularFonts() ? 15 : 5)
            .padding(.vertical, 10)
            if usingRegularFonts() {
                Image(systemName: "location.circle")
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
                    .font(.title3)
                    .padding(.trailing)
                    .padding(.leading, 7)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(R.string.localizable.yourLocationIs()) \(location!.locationDisplay)"))
        .accessibilityAddTraits(.isButton)
    }
    
    var unsetLocationView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(R.string.localizable.setYourLocation)
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(R.string.localizable.setYourLocation))
        .accessibilityAddTraits(.isButton)
    }
}

struct LocationHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LocationHeader(location: nil, fetchingContacts: true)
            LocationHeader(location: nil, fetchingContacts: false)
            LocationHeader(location: UserLocation(address: "19444"), fetchingContacts: false)
                .frame(maxWidth: 250)
            Spacer()
        }
    }
}
