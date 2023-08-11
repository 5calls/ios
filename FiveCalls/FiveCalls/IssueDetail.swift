//
//  IssueDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/11/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueDetail: View {
    let issue: Issue
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                Text(issue.markdownAttributedString)
                    .padding(.horizontal)
            }
        }
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static var previews: some View {
        IssueDetail(issue: Issue.multilinePreviewIssue)
    }
}
