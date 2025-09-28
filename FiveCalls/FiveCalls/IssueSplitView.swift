//
//  IssueSplitView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 11/1/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct IssueSplitView: View {
    @EnvironmentObject var store: Store
    @Environment(\.horizontalSizeClass) private var originalSizeClass
    
    var body: some View {
        TabView(selection: $store.state.selectedTab) {
            NavigationSplitView(columnVisibility: .constant(.all)) {
                Dashboard(selectedIssue: $store.state.issueRouter.selectedIssue)
            } detail: {
                NavigationStack(path: $store.state.issueRouter.path) {
                    if let selectedIssue = store.state.issueRouter.selectedIssue {
                        IssueDetail(issue: selectedIssue)
                            .id(selectedIssue.id)
                            .toolbar(.hidden, for: .tabBar)
                            .navigationDestination(for: IssueDetailNavModel.self) { idnm in
                                IssueContactDetail(issue: idnm.issue, remainingContacts: idnm.contacts)
                            }
                            .navigationDestination(for: IssueDoneNavModel.self) { inm in
                                IssueDone(issue: inm.issue)
                            }
                    } else {
                        VStack(alignment: .leading) {
                            Text(R.string.localizableR.chooseIssuePlaceholder())
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Text(R.string.localizableR.chooseIssueSubheading())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationSplitViewStyle(.balanced)
            .tabItem({ Label(R.string.localizableR.tabTopics(), systemImage: "phone.bubble.fill" ) })
            .tag("topics")
            // Set the inner size class for the navigation stack back to whatever it was originally since we override it for old tab bar behavior below
            .environment(\.horizontalSizeClass, originalSizeClass)
            .toolbar(.visible, for: .tabBar)
            
            InboxView()
                .tabItem({ Label(R.string.localizableR.tabReps(), systemImage: "person.crop.circle.fill.badge.checkmark") })
                .tag("inbox")
        }// the new TabBar style in iOS 18 does not work well with this style, for now override the size class so it uses the old style on iPadOS
        .environment(\.horizontalSizeClass, .compact)
    }
}

struct IssueSplitView_Previews: PreviewProvider {
    static let previewState = {
        var state = AppState()
        state.issues = [
            Issue.basicPreviewIssue,
            Issue.multilinePreviewIssue
        ]
        state.contacts = [
            Contact.housePreviewContact,
            Contact.senatePreviewContact1,
            Contact.senatePreviewContact2
        ]
        return state
    }()

    static let store = Store(state: previewState, middlewares: [appMiddleware()])
    
    static var previews: some View {
        IssueSplitView().environmentObject(store)
    }
}
