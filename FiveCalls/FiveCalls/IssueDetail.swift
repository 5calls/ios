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
            VStack(alignment: .leading, spacing: 0) {
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 16)
                Text(issue.markdownIssueReason)
                    .padding(.bottom, 16)
                Text("Relevant representatives for this issue:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
                    .padding(.leading, 6)
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 120)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                HStack {
                    Text("See your script")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(.white)
                }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(.blue)
                    }
                    
                
            }.padding(.horizontal)

        }
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static var previews: some View {
        IssueDetail(issue: Issue.multilinePreviewIssue)
    }
}
