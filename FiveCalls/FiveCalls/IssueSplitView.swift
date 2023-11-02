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
    @StateObject var router: IssueRouter = IssueRouter()
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), sidebar: {
            Dashboard(selectedIssue: $router.selectedIssue).environmentObject(router)
        }, detail: {
            NavigationStack(path: $router.path) {
                if let selectedIssue = router.selectedIssue {
                    IssueDetail(issue: selectedIssue, 
                                contacts: selectedIssue.contactsForIssue(allContacts: store.state.contacts))
                        .environmentObject(router)
                    .navigationDestination(for: IssueDetailNavModel.self) { idnm in
                        IssueContactDetail(issue: idnm.issue, remainingContacts: idnm.contacts)
                            .environmentObject(router)
                    }.navigationDestination(for: IssueNavModel.self) { inm in
                        IssueDone(issue: inm.issue)
                            .environmentObject(router)
                    }
                } else {
                    Text("Please select an issue")
                }
            }
        })
        .navigationSplitViewStyle(.balanced)
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
