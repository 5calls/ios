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
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            
            Text(R.string.localizable.whatsImportantTitle())
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .accessibilityAddTraits(.isHeader)

            IssuesList(store: store, selectedIssue: $selectedIssue, showAllIssues: $showAllIssues)
        }
        .navigationBarHidden(true)
        .onAppear() {
            AnalyticsManager.shared.trackPageview(path: "/")
            
            // TODO: refresh if issues are old too?
            if store.state.issues.isEmpty {
                store.dispatch(action: .FetchIssues)
            }
            
            if let location = store.state.location, store.state.contacts.isEmpty {
                store.dispatch(action: .FetchContacts(location))
            }
        }
        .onOpenURL(perform: { url in
            if store.state.issues.isEmpty {
                store.state.issueLoadedCallback = {
                    selectIssue(fromURL: url)
                    store.state.issueLoadedCallback = nil
                }
            } else {
                selectIssue(fromURL: url)
            }
        })
    }
    
    func selectIssue(fromURL url: URL) {
        store.state.issues.forEach { issue in
            if issue.slug == url.lastPathComponent {
                selectedIssue = issue
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
            Image(systemName: "gear")
                .renderingMode(.template)
                .font(.title)
                .tint(Color.fivecallsDarkBlue)
                .accessibilityLabel(Text(R.string.localizable.menuName))
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
        if !showAllIssues {
            // if we're showing the default list, make fake categories to preserve the json order. The category names don't matter because we don't show them on the default list
            return allIssues.map({ CategorizedIssuesViewModel(category: Category(name: "\($0.id)"), issues: [$0]) })
        }
        
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
        ScrollViewReader { scroll in
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
                        Button {
                            showAllIssues.toggle()
                            if let issueID = categorizedIssues.first?.issues.first?.id {
                                scroll.scrollTo(issueID, anchor: .top)
                            }
                        } label: {
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
}
