//
//  Dashboard.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var store: Store

    @State var showLocationSheet = false

    let op = Operator()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    LocationHeader(location: store.state.location, fetchingContacts: store.state.fetchingContacts)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            showLocationSheet.toggle()
                        }
                        .sheet(isPresented: $showLocationSheet) {
                            LocationSheet()
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.visible)
                                .padding(.top, 40)
                            Spacer()
                        }
                    Text("What’s important to you?")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    ForEach(store.state.issues) { issue in
                        NavigationLink(value: issue) {
                            IssueListItem(issue: issue, contacts: store.state.contacts)
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
                if store.state.issues.isEmpty {
                    store.dispatch(action: FetchIssuesAction())
                }
        
                if let location = store.state.location, store.state.contacts.isEmpty {
                    store.dispatch(action: FetchContactsAction(location: location))
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
