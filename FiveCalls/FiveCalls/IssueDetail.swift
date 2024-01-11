//
//  IssueDetail.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 8/11/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueDetail: View {
    @EnvironmentObject var store: Store

    let issue: Issue
    let contacts: [Contact]
    
    @State var showLocationSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                IssueNavigationHeader(issue: issue)
                    .padding(.bottom, 8)
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.bottom, 8)
                Text(issue.markdownIssueReason)
                    .padding(.bottom, 16)
                if contacts.count > 0 {
                    Text(R.string.localizable.repsListHeader())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                        .padding(.leading, 6)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(contacts.numbered(), id: \.element.id) { contact in
                        ContactListItem(contact: contact.element, showComplete: store.state.issueCalledOn(issueID: issue.id, contactID: contact.id))
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.fivecallsLightBG)
                            }
                    }
                    .padding(.bottom, 16)
                    NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: contacts)) {
                        PrimaryButton(title: R.string.localizable.seeScript(), systemImageName: "megaphone.fill")
                    }
                } else {
                    Text(R.string.localizable.setLocationHeader())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                        .padding(.leading, 6)
                    Button(action: {
                        showLocationSheet.toggle()
                    }, label: {
                        PrimaryButton(title: R.string.localizable.setLocationButton(), systemImageName: "location.circle.fill")
                    })
                }
            }.padding(.horizontal)
        }
        .navigationBarHidden(true)
        .clipped()
        .sheet(isPresented: $showLocationSheet) {
            LocationSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .padding(.top, 40)
            Spacer()
        }
        .onAppear() {
            AnalyticsManager.shared.trackPageview(path: "/issue/\(issue.slug)/")
        }
    }
}

#Preview {
    IssueDetail(issue: .basicPreviewIssue, contacts: [.housePreviewContact,.senatePreviewContact1,.senatePreviewContact2])
        .environmentObject(Store(state: AppState()))
}

struct IssueDetailNavModel {
    var issue: Issue
    let contacts: [Contact]
}

extension IssueDetailNavModel: Equatable, Hashable {
    static func == (lhs: IssueDetailNavModel, rhs: IssueDetailNavModel) -> Bool {
        return lhs.issue.id == rhs.issue.id && lhs.contacts.elementsEqual(rhs.contacts)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(issue.id)
        hasher.combine(contacts.compactMap({$0.id}).joined())
    }
}
