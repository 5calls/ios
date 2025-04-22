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
    @AppStorage("shownNewsletterSignup") var shownNewsletterSignup: Bool = false
    
    @State var selectedIssueUrl: URL?
    @Binding var selectedIssue: Issue?

    @State var showAllIssues = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func usingRegularFonts() -> Bool {
        dynamicTypeSize < DynamicTypeSize.accessibility3
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MainHeader()
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
            
            if !shownNewsletterSignup {
                NewsletterSignup {
                    shownNewsletterSignup = true
                } onSubmit: { email in
                    var district = store.state.district
#if !DEBUG
                    var req = URLRequest(url: URL(string: "https://buttondown.com/api/emails/embed-subscribe/5calls")!)
                    req.httpMethod = "POST"
                    req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    var reqBody = "email=\(email)&tag=ios"
                    if let district { reqBody += "&tag=\(district)" }
                    req.httpBody = reqBody.data(using: .utf8)
                    URLSession.shared.dataTask(with: req).resume()
#else
                    var subscribeDebug = "DEBUG: would send email sub request to: \(email)"
                    if let district { subscribeDebug += " with district: \(district)"}
                    print(subscribeDebug)
#endif
                    
                    shownNewsletterSignup = true
                }
            }

            if usingRegularFonts() {
                Text(R.string.localizable.whatsImportantTitle())
                    .font(.body)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, 16)
            }

            IssuesList(store: store, selectedIssue: $selectedIssue, showAllIssues: $showAllIssues)
        }
        .navigationBarHidden(true)
        .onAppear() {
            AnalyticsManager.shared.trackPageview(path: "/")

            if let location = store.state.location, store.state.contacts.isEmpty {
                store.dispatch(action: .FetchContacts(location))
            }
        }
        .onOpenURL(perform: { url in
            if store.state.issues.isEmpty {
                selectedIssueUrl = url
            } else {
                selectedIssue = store.state.issues.first(where: { $0.slug == url.lastPathComponent })
            }
        })

        .onChange(of: store.state.issues) { issues in
            if let selectedIssueUrl {
                selectedIssue = issues.first(where: { $0.slug == selectedIssueUrl.lastPathComponent })
                self.selectedIssueUrl = nil
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
        NavigationStack {
            Dashboard(selectedIssue: .constant(.none)).environmentObject(store)
        }
    }
}

struct MenuView: View {
    @State var showRemindersSheet = false
    @State var showYourImpact = false
    @State var showAboutSheet = false
    var showingWelcomeScreen: Bool

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
                        .listRowSeparatorTint(.fivecallsDarkGray)
                    }
                } header: {
                    if showAllIssues {
                        Text(section.name.uppercased()).font(.headline)
                            .foregroundStyle(.fivecallsDarkGray)
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
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.fivecallsDarkBlueText)

                        }
                        .padding(.vertical, 10)
                        .listRowSeparatorTint(.fivecallsDarkGray)
                    }
                }
            }
            .tint(Color.fivecallsLightBG)
            .listStyle(.plain)
        }
    }
}
