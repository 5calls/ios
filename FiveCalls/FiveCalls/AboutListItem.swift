//
//  AboutListItem.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/26/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct AboutListItem: View {
    var title: String
    var action: (() -> Void)?
    var navigationLinkValue: WebViewContent?
    var url: URL?

    @ViewBuilder
    var body: some View {
        if let action {
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
        } else if let navigationLinkValue {
            HStack {
                ZStack {
                    NavigationLink("", value: navigationLinkValue)
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
        } else if let url {
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
        }
    }
}

#Preview {
    VStack {
        AboutListItem(title: "test item nav link", navigationLinkValue: WebViewContent.whycall)
        AboutListItem(title: "test item action") { let showEmailComposer = true }
        AboutListItem(title: "test url", url: URL(string: "https://google.com"))
    }
}
