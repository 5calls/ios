//
//  AboutListItem.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/26/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import AcknowList
import SwiftUI

enum AboutListItemType {
    case action(() -> Void)
    case url(URL)
    case acknowledgements
}

struct AboutListItem: View {
    var title: LocalizedStringResource
    var type: AboutListItemType

    @ViewBuilder
    var body: some View {
        switch type {
        case let .action(action):
            Button(action: action) {
                HStack {
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .renderingMode(.template)
                        .tint(.primary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        case let .url(url):
            ShareLink(item: url) {
                HStack {
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .renderingMode(.template)
                        .tint(.primary)
                        .accessibilityHidden(true)
                }
                .accessibilityAddTraits(.isButton)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        case .acknowledgements:
            HStack {
                ZStack {
                    NavigationLink {
                        AcknowListView()
                            .navigationTitle(
                                String(
                                    localized: "Open Source",
                                    comment: "AcknowListView navigation title"
                                )
                            )
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(.visible)
                            .toolbarBackground(Color.fivecallsDarkBlue)
                            .toolbarColorScheme(.dark, for: .navigationBar)
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                    HStack {
                        Text(title)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .renderingMode(.template)
                    .tint(.primary)
                    .accessibilityHidden(true)
            }
            .accessibilityAddTraits(.isButton)

        }
    }
}

#Preview {
    VStack {
        AboutListItem(title: "test item action", type: .action({ let _ = true }))
        AboutListItem(title: "test url", type: .url(URL(string: "https://google.com")!))
        AboutListItem(title: "test acknowledgements", type: .acknowledgements)
    }
}
