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
    let remainingContacts: [Contact]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 16)
                ContactListItem(contact: currentContact())
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.fivecallsLightBG)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        Text(currentContact().phone)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.fivecallsDarkBlueText)
                        Menu {
                            ForEach(currentContact().fieldOffices) { office in
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
                                .foregroundColor(Color.fivecallsDarkBlue)
                                .padding(.leading, 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                Text(issue.markdownIssueScript)
                    .padding(.horizontal)
                if remainingContacts.count > 1 {
                    NavigationLink(destination: IssueContactDetail(issue: issue, remainingContacts: nextContacts())) {
                        PrimaryButton(title: nextButtonTitle(),
                                      systemImageName: "megaphone.fill")
                        .padding()
                    }
                } else {
                    NavigationLink(destination: IssueDone(issue: issue)) {
                        PrimaryButton(title: "Done calling",
                                      systemImageName: "megaphone.fill")
                        .padding()
                    }
                }
                Spacer()
            }
        }.navigationBarHidden(true)
        .clipped()
    }
    
    func currentContact() -> Contact {
        return remainingContacts.first!
    }
    
    func nextContacts() -> [Contact] {
        return Array(remainingContacts.dropFirst())
    }
    
    func nextButtonTitle() -> String {
        return "Next contact"
    }
}

struct IssueContactDetail_Previews: PreviewProvider {
    static var previews: some View {
        IssueContactDetail(issue: Issue.basicPreviewIssue, remainingContacts: [Contact.housePreviewContact])
    }
}
