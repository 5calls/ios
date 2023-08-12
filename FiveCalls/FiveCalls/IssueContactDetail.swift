//
//  IssueContactDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/11/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueContactDetail: View {
    let issue: Issue
    let contact: Contact
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ContactCircle(contact: contact)
                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .padding(.leading, 8)
                VStack(alignment: .leading) {
                    Text(contact.name)
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("US House Rep. District 13")
                        .font(.subheadline)
                    
                }
                Spacer()
            }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                }
                .padding(.horizontal)
                .padding(.bottom)
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text(contact.phone)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Menu {
                        Section("Local offices") {
                            ForEach(contact.fieldOffices) { office in
                                Button{ } label: {
                                    VStack {
                                        Text("\(office.phone)\n(\(office.city))")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .padding(6)
                            .background() {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                            }
                    }
                }
//                Text("Tap to dial")
//                    .font(.caption)
            }
                .padding(.horizontal)
                .padding(.bottom)
            Text(issue.markdownIssueScript)
                .padding(.horizontal)
        }

    }
}

struct IssueContactDetail_Previews: PreviewProvider {
    static var previews: some View {
        IssueContactDetail(issue: Issue.basicPreviewIssue, contact: Contact.housePreviewContact)
    }
}
