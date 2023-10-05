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
                        .foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                }
            }
        } else if let navigationLinkValue {
            HStack {
                ZStack {
                    NavigationLink("", value: navigationLinkValue)
                        .opacity(0)
                    HStack {
                        Text(title)
                        Spacer()
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
            }
        } else if let url {
            ShareLink(item: url) {
                HStack {
                    Text(title)
                        .foregroundStyle(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)              
                }
            }
        }
    }
}

