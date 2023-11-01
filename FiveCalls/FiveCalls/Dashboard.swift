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
    @Binding var selectedIssue: Issue?

    @State var showLocationSheet = false
    @State var showRemindersSheet = false
    @State var showYourImpact = false
    @State var showAboutSheet = false

    var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Menu {
                        Button(action: {
                            showRemindersSheet.toggle()
                        }, label: {
                            Text(R.string.localizable.menuScheduledReminders())
                        })
                        Button(action: {
                            showYourImpact.toggle()
                        }, label: {
                            Text(R.string.localizable.menuYourImpact())
                        })
                        Button(action: {
                            showAboutSheet.toggle()
                        }, label: {
                            Text(R.string.localizable.menuAbout())
                        })
                    } label: {
                        Image(.gear).renderingMode(.template).tint(Color.fivecallsDarkBlue)
                    }
                    .popoverTipIfApplicable(
                        title: Text(R.string.localizable.menuTipTitle()),
                        message: Text(R.string.localizable.menuTipMessage()))
                    .sheet(isPresented: $showRemindersSheet) {
                        ScheduleReminders()
                    }
                    .sheet(isPresented: $showYourImpact) {
                        YourImpact()
                    }
                    .sheet(isPresented: $showAboutSheet) {
                        AboutSheet()
                    }
                    
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
                    
                    Image(.fivecallsStars)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                
                Text(R.string.localizable.whatsImportantTitle())
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                List(store.state.issues, selection: $selectedIssue) { issue in
                    NavigationLink(value: issue) {
                        IssueListItem(issue: issue, contacts: store.state.contacts)
                    }
                }
                .listStyle(.plain)
            }
        .navigationBarHidden(true)
        .onAppear() {
            //              TODO: refresh if issues are old too?
            if store.state.issues.isEmpty {
                store.dispatch(action: .FetchIssues)
            }
            
            if let location = store.state.location, store.state.contacts.isEmpty {
                store.dispatch(action: .FetchContacts(location))
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

    static let store = Store(state: previewState, middlewares: [appMiddleware()])
    
    static var previews: some View {
        Dashboard(selectedIssue: .constant(.none)).environmentObject(store)
    }
}
