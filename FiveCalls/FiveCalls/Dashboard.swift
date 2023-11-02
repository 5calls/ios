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
    @State var showAllIssues = false
    
    var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        MenuView()

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
                                        
                    IssuesList(store: store, selectedIssue: $selectedIssue, showAllIssues: $showAllIssues)
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
                }.padding(.horizontal, 10)
            }.navigationDestination(for: Issue.self) { issue in
                IssueDetail(issue: issue, contacts: issue.contactsForIssue(allContacts: store.state.contacts))
            }.navigationDestination(for: IssueDetailNavModel.self) { idnm in
                IssueContactDetail(issue: idnm.issue, remainingContacts: idnm.contacts)
            }.navigationDestination(for: IssueNavModel.self) { inm in
                IssueDone(issue: inm.issue, contacts: inm.contacts)
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

struct MenuView: View {
    @State var showRemindersSheet = false
    @State var showYourImpact = false
    @State var showAboutSheet = false

    var body: some View {
        Menu {
            Button { showRemindersSheet.toggle() } label: {
                Text(R.string.localizable.menuScheduledReminders())
            }
            Button { showYourImpact.toggle() } label: {
                Text(R.string.localizable.menuYourImpact())
            }
            Button { showAboutSheet.toggle() } label: {
                Text(R.string.localizable.menuAbout())
            }
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
    }
}

struct IssuesList: View {
    @ObservedObject var store: Store
    @Binding var selectedIssue: Issue?
    @Binding var showAllIssues: Bool
    
    var allIssues: [Issue] {
        if showAllIssues {
            return store.state.issues
        } else {
            return store.state.issues.filter({ $0.active })
        }
    }
    
    private var categorizedIssues: [CategorizedIssuesViewModel] {
        var categoryViewModels = Set<CategorizedIssuesViewModel>()
        for issue in allIssues {
            for category in issue.categories {
                if let categorized = categoryViewModels.first(where: { $0.category == category }) {
                    categorized.issues.append(issue)
                } else {
                    categoryViewModels.insert(CategorizedIssuesViewModel(category: category, issues: [issue]))
                }
            }
        }
        return Array(categoryViewModels).sorted(by: { $0.category < $1.category })
    }

    var body: some View {
        List(categorizedIssues, selection: $selectedIssue) { section in
            Section {
                ForEach(section.issues) { issue in
                    NavigationLink(value: issue) {
                        IssueListItem(issue: issue, contacts: store.state.contacts)
                    }
                }
            } header: {
                if showAllIssues {
                    Text(section.name.uppercased()).font(.headline)
                }
            } footer: {
                if section == categorizedIssues.last {
                    Button { showAllIssues.toggle() } label: {
                        Text(showAllIssues ? R.string.localizable.lessIssuesTitle() : 
                                R.string.localizable.moreIssuesTitle())
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.fivecallsDarkBlueText)
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .tint(Color.fivecallsLightBG)
        .listStyle(.plain)
    }
}
