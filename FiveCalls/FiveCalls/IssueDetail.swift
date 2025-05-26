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
    @State private var forceRefreshID = UUID()
    
    var vacantAreas: [String] {
        store.state.missingReps.filter(issue.contactAreas.contains)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(issue.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.top, 1)
                    .padding(.bottom, 8)
                Text(issue.markdownIssueReason)
                    .padding(.bottom, 16)
                    .accentColor(.fivecallsDarkBlueText)
                if store.state.location != nil {
                    Text(R.string.localizable.repsListHeader())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                        .padding(.leading, 6)
                        .accessibilityAddTraits(.isHeader)
                    VStack(spacing: 0) {
                        ForEach(contacts.numbered(), id: \.element.id) { contact in
                            NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: Array(contacts[contact.number..<contacts.endIndex]))) {
                                ContactListItem(contact: contact.element, showComplete: store.state.issueCalledOn(issueID: issue.id, contactID: contact.id))
                                    .id(forceRefreshID)
                            }
                            // Display divider if we are not done with the contact list
                            // or if we are done with contacts and there is a vacancy to show
                            if contact.number < contacts.count - 1 || contact.number == contacts.count - 1 && !vacantAreas.isEmpty {
                                Divider()
                            }
                        }
                        
                        ForEach(vacantAreas, id: \.self) { area in
                            let contact = Contact(area: area, name: R.string.localizable.vacantSeatTitle())
                            let note = R.string.localizable.vacantSeatMessage(area)
                            
                            ContactListItem(contact: contact, contactNote: note)
                                .opacity(0.5)
                            if area != vacantAreas.last {
                                Divider()
                            }
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.fivecallsLightBG)
                    }
                    .padding(.bottom, 16)
                    
                    if contacts.count > 0 {
                        NavigationLink(value: IssueDetailNavModel(issue: issue, contacts: contacts)) {
                            PrimaryButton(title: R.string.localizable.seeScript(), systemImageName: "megaphone.fill")
                        }
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
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
        .sheet(isPresented: $showLocationSheet) {
            LocationSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .padding(.top, 40)
            Spacer()
        }
        .onAppear {
            // Force refresh id so that async images can load. See https://github.com/5calls/ios/issues/465
            forceRefreshID = UUID()
            
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
