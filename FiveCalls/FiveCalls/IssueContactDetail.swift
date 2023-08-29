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
            ContactListItem(contact: contact)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.FiveCallsLightBG)
                }
                .padding(.horizontal)
                .padding(.bottom)
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text(contact.phone)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.FiveCallsDarkBlueText)
                    Menu {
                        ForEach(contact.fieldOffices) { office in
                            Section(office.city) {
                                Button{ } label: {
                                    VStack {
                                        Text(office.phone)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(Color.FiveCallsDarkBlue)
                            .padding(.leading, 4)
                    }
                }
            }
                .padding(.horizontal)
                .padding(.bottom)
            Text(issue.markdownIssueScript)
                .padding(.horizontal)
            PrimaryButton(title: nextButtonTitle(), systemImageName: "megaphone.fill")
                .padding()
            Spacer()
        }
    }
    
    func nextButtonTitle() -> String {
        return "Next contact"
    }
}

struct IssueContactDetail_Previews: PreviewProvider {
    static var previews: some View {
        IssueContactDetail(issue: Issue.basicPreviewIssue, contact: Contact.housePreviewContact)
    }
}
