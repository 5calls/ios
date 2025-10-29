// Copyright 5calls. All rights reserved. See LICENSE for details.

import StoreKit
import SwiftUI

private let appId = "1202558609"
private let appUrl = URL(string: "https://itunes.apple.com/us/app/myapp/id\(appId)?ls=1&mt=8")

struct AboutSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: Store

    @State var showEmailComposer = false
    @State var showEmailComposerAlert = false
    @State var showWelcome = false
    @State private var callingGroup: String = UserDefaults.standard.string(forKey: UserDefaultsKey.callingGroup.rawValue) ?? ""

    private var versionString: String? = {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }

        return "v\(version) - \(AnalyticsManager.shared.callerID)"
    }()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    AboutListItem(
                        title: LocalizedStringResource(
                            "Why Calling Works",
                            comment: "AboutListItem title"
                        ),
                        type: .action {
                            openSocialLink("https://5calls.org/why-calling-works/")
                        }
                    )
                    AboutListItem(
                        title: LocalizedStringResource(
                            "Who Made 5 Calls?",
                            comment: "AboutListItem title"
                        ),
                        type: .action {
                            openSocialLink("https://5calls.org/about-us/")
                        }
                    )
                    AboutListItem(
                        title: LocalizedStringResource(
                            "Feedback",
                            comment: "AboutListItem title"
                        ),
                        type: .action {
                            if EmailComposerView.canSendEmail() {
                                showEmailComposer = true
                            } else {
                                showEmailComposerAlert = true
                            }
                        }
                    )
                    .sheet(isPresented: $showEmailComposer) {
                        EmailComposerView { _ in }
                    }
                    .alert(isPresented: $showEmailComposerAlert) {
                        Alert(
                            title: Text("Can't send mail", comment: "AboutSheet alert title"),
                            message: Text(
                                "Please configure an e-mail address in the Settings app",
                                comment: "About sheet alert body"
                            ),
                            dismissButton: .default(Text("Dismiss", comment: "Standard Dismiss Button text"))
                        )
                    }
                    AboutListItem(
                        title: LocalizedStringResource(
                            "Show Welcome Screen",
                            comment: "AboutListItem title"
                        ),
                        type: .action {
                            showWelcome = true
                        }
                    )
                    .sheet(isPresented: $showWelcome, content: {
                        Welcome()
                    })
                } header: {
                    Text("General", comment: "About Section Header")
                        .textCase(.uppercase)
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    TextField(
                        String(
                            localized: "Enter your calling group name",
                            comment: "AboutSheet calling group placeholder text"
                        ),
                        text: $callingGroup
                    )
                    .onChange(of: callingGroup) {
                        let trimmed = callingGroup.trimmingCharacters(in: .whitespaces)
                        if trimmed != callingGroup {
                            callingGroup = trimmed
                        }
                        UserDefaults.standard.set(trimmed, forKey: UserDefaultsKey.callingGroup.rawValue)
                    }
                } header: {
                    Text("Calling Group", comment: "AboutSheet Section Header")
                        .textCase(.uppercase)
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text(
                        "Set a calling group name to track calls with others",
                        comment: "AboutSheet section footer"
                    )
                    .font(.footnote)
                    .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    AboutListItem(
                        title: "Instagram",
                        type: .action {
                            openSocialLink("https://www.instagram.com/5calls")
                        }
                    )
                    AboutListItem(
                        title: "Bluesky",
                        type: .action {
                            openSocialLink("https://bsky.app/profile/5calls.org")
                        }
                    )
                    AboutListItem(
                        title: "Threads",
                        type: .action {
                            openSocialLink("https://www.threads.net/@5calls")
                        }
                    )
                    AboutListItem(
                        title: "Mastodon",
                        type: .action {
                            openSocialLink("https://mastodon.social/@5calls")
                        }
                    )
                    if appUrl != nil {
                        AboutListItem(
                            title: LocalizedStringResource(
                                "Share with Others",
                                comment: "AboutListItem title"
                            ),
                            type: .url(appUrl!)
                        )
                    }
                    AboutListItem(
                        title: LocalizedStringResource(
                            "Please Rate 5 Calls",
                            comment: "AboutListItem title"
                        ),
                        type: .action {
                            requestReview()
                        }
                    )
                } header: {
                    Text("Follow us on your favorite platform", comment: "About section header")
                        .textCase(.uppercase)
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text("Sharing and Rating helps others find 5 Calls", comment: "About section footer")
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    AboutListItem(
                        title: LocalizedStringResource(
                            "Open Source Libraries",
                            comment: "AboutListItem title"
                        ),
                        type: .acknowledgements
                    )
                } header: {
                    Text("Credits", comment: "About section header")
                        .textCase(.uppercase)
                }

                if let versionString {
                    Section(
                        footer: HStack {
                            Spacer()
                            Text(versionString)
                                .font(.footnote)
                                .foregroundStyle(.fivecallsDarkGray)
                            Spacer()
                        },
                        content: {}
                    )
                }
            }
            .listStyle(.grouped)
            .navigationTitle(String(localized: "About", comment: "AboutSheet navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible)
            .toolbarBackground(Color.fivecallsDarkBlue)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done", comment: "Standard Done Button text")
                            .bold()
                    }
                }
            }.navigationDestination(for: WebViewContent.self) { webViewContent in
                WebView(webViewContent: webViewContent)
                    .navigationTitle(webViewContent.navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.visible)
                    .toolbarBackground(Color.fivecallsDarkBlue)
                    .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
        .accentColor(.white)
    }

    func openSocialLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    func requestReview() {
        guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        SKStoreReviewController.requestReview(in: currentScene)
    }
}

#Preview {
    AboutSheet()
}
