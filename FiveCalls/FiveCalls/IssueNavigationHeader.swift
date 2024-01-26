//
//  IssueNavigationHeader.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueNavigationHeader: View {
    @EnvironmentObject var store: Store

    let issue: Issue

    var body: some View {
        HStack(alignment: .top) {
            Button {
                store.dispatch(action: .GoBack)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName
                        .font(.body)
                    Text(R.string.localizable.back())
                        .fontWeight(.medium)
                }
            }
            Spacer()
            ShareLink(item: issue.shareURL) {
                HStack(spacing: 4) {
                    Text(R.string.localizable.share())
                        .fontWeight(.medium)
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .offset(y: -1)
                }
            }
        }
    }
}

#Preview {
    IssueNavigationHeader(issue: .basicPreviewIssue)
}
