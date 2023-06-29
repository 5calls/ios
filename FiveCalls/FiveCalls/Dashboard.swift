//
//  Dashboard.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Dashboard: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("What’s important to you?")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                ForEach(0..<5) { _ in
                    IssueListItem(issue: Issue.basicPreviewIssue)
                }
            }.padding(.horizontal, 10)
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}
