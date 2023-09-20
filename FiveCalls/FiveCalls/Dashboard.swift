//
//  Dashboard.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var appState: AppState

    @State var showLocationSheet = false

    let op = Operator()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    LocationHeader(location: appState.location, fetchingContacts: appState.fetchingContacts)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            showLocationSheet.toggle()
                        }
                        .sheet(isPresented: $showLocationSheet) {
                            LocationSheet(location: appState.location, setLocation: appState.setLocation)
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.visible)
                                .padding(.top, 40)
                            Spacer()
                        }
                    Text("What’s important to you?")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    ForEach(appState.issues) { issue in
                        NavigationLink(value: issue) {
                            IssueListItem(issue: issue, contacts: appState.contacts)
                        }
                    }
                }.padding(.horizontal, 10)
            }.navigationTitle("Issues")
            .navigationDestination(for: Issue.self) { issue in
                IssueDetail(issue: issue)
            }
            .navigationBarHidden(true)
            .onAppear() {
//              TODO: refresh if issues are old too?
                if appState.issues.isEmpty {
                    op.fetchIssues(setIssues: appState.setIssues)
                }
        
                if let location = appState.location, appState.contacts.isEmpty {
                    op.fetchContacts(location: location, fetching: appState.setFetchingContacts, setContacts: appState.setContacts)
                }
            }
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
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
    
    static var previews: some View {
        Dashboard().environmentObject(previewState)
    }
}
