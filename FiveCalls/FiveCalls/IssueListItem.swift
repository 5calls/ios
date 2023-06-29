//
//  IssueListItem.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueListItem: View {
    let issue: Issue
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .clipped()
            VStack {
                HStack {
                    Circle()
                        .stroke(Color(.tertiaryLabel), lineWidth: 4)
                        .background(Circle().fill(Color(.quaternaryLabel)))
                        .frame(width: 50)
                        .padding(.vertical, 12)
                        .padding(.leading, 12)
                    VStack(alignment: .leading) {
                        Text(issue.name)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("darkBlueText"))
                            .lineLimit(2)
                        Spacer()
                        HStack(spacing: 0) {
                            Circle()
                                .fill(.red)
                                .frame(width: 20)
                                .clipped()
                            Circle()
                                .fill(.green)
                                .frame(width: 20)
                                .clipped()
                                .offset(x: -10, y: 0)
                            Circle()
                                .fill(.blue)
                                .frame(width: 20)
                                .clipped()
                                .offset(x: -20, y: 0)
                            Text("Call House Rep, Senators")
                                .font(.footnote)
                                .offset(x: -15, y: 0)
                        }
                    }
                    .padding(.leading, 6)
                    .padding(.vertical, 10)
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .imageScale(.large)
                        .symbolRenderingMode(.monochrome)
                        .padding(.trailing, 10)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(.sRGB, red: 23/255, green: 116/255, blue: 209/255))
                }
            }
        }
        .clipped()

    }
}

struct IssueListItem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            IssueListItem(issue: Issue.basicPreviewIssue)
                .padding(.horizontal, 10)
            IssueListItem(issue: Issue.multilinePreviewIssue)
                .padding(.horizontal, 10)
        }
    }
}
