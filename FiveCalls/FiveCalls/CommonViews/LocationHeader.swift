// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

struct LocationHeader: View {
    let location: UserLocation?
    let isSplit: Bool
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
                Text("Your location is:", comment: "Location View Title Text")
                    .font(.footnote)
                if isSplit {
                    Text(
                        verbatim: "\(Image(systemName: "exclamationmark.triangle")) \(location!.locationDisplay)"
                    )
                    .font(.system(.title3))
                    .fontWeight(.medium)
                } else {
                    Text(location!.locationDisplay)
                        .font(.system(.title3))
                        .fontWeight(.medium)
                }
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
        .accessibilityLabel(
            Text(
                "\"Your location is: \(location!.locationDisplay)",
                comment: "LocationView Accessibility Label"
            )
        )
        .accessibilityAddTraits(.isButton)
    }

    var unsetLocationView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(
                    "Set your location to find your representatives",
                    comment: "UnsetLocationView Title Text"
                )
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
        .accessibilityLabel(
            Text(
                "Set your location to find your representatives",
                comment: "UnsetLocationView Accessibility Label"
            )
        )
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack {
        LocationHeader(location: nil, isSplit: false, fetchingContacts: true)
        LocationHeader(location: nil, isSplit: true, fetchingContacts: false)
        LocationHeader(
            location: UserLocation(address: "19444"),
            isSplit: false, fetchingContacts: false
        )
        .frame(maxWidth: 250)
        LocationHeader(
            location: UserLocation(address: "48184"),
            isSplit: true, fetchingContacts: false
        )
        .frame(maxWidth: 250)
        Spacer()
    }
}
