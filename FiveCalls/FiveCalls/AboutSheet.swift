//
//  AboutSheet.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/18/23.
//  Copyright © 2023 5calls. All rights reserved.
//

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
                    AboutListItem(title: R.string.localizable.aboutItemWhyCall(),
                                  type: .webViewContent(WebViewContent.whycall))
                    AboutListItem(title: R.string.localizable.aboutItemWhoWeAre(), 
                                  type: .webViewContent(WebViewContent.whoweare))
                    .navigationDestination(for: WebViewContent.self) { webViewContent in
                        WebView(webViewContent: webViewContent)
                            .navigationTitle(webViewContent.navigationTitle)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(.visible)
                            .toolbarBackground(Color.fivecallsDarkBlue)
                            .toolbarColorScheme(.dark, for: .navigationBar)
                    }
                    AboutListItem(title: R.string.localizable.aboutItemFeedback(),
                                  type: .action({
                        if EmailComposerView.canSendEmail() {
                            showEmailComposer = true
                        } else {
                            showEmailComposerAlert = true
                        }
                    }))
                    .sheet(isPresented: $showEmailComposer){
                        EmailComposerView() { _ in }
                    }
                    .alert(isPresented: $showEmailComposerAlert) {
                        Alert(title: Text(R.string.localizable.cantSendEmailTitle()),
                              message: Text(R.string.localizable.cantSendEmailMessage()),
                              dismissButton: .default(Text(R.string.localizable.dismissTitle())))
                    }
                    AboutListItem(title: R.string.localizable.aboutItemShowWelcome(),
                                  type: .action({
                        showWelcome = true
                    }))
                    .sheet(isPresented: $showWelcome, content: {
                        Welcome()
                    })
                } header: {
                    Text(R.string.localizable.aboutSectionHeaderGeneral().uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    AboutListItem(title: "Instagram",
                                  type: .action({
                        openSocialLink("https://www.instagram.com/5calls")
                    }))
                    AboutListItem(title: "Bluesky",
                                  type: .action({
                        openSocialLink("https://bsky.app/profile/5calls.org")
                    }))
                    AboutListItem(title: "Threads",
                                  type: .action({
                        openSocialLink("https://www.threads.net/@5calls")
                    }))
                    AboutListItem(title: "Mastodon",
                                  type: .action({
                        openSocialLink("https://mastodon.social/@5calls")
                    }))
                    if appUrl != nil {
                        AboutListItem(title: R.string.localizable.aboutItemShare(),
                                      type: .url(appUrl!))
                    }
                    AboutListItem(title: R.string.localizable.aboutItemRate(),
                                  type: .action({
                        requestReview()
                    }))
                } header: {
                    Text(R.string.localizable.aboutSectionHeaderSocial().uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text(R.string.localizable.aboutSectionFooterSocial())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    AboutListItem(title: R.string.localizable.aboutItemOpenSource(),
                                  type: .acknowledgements)
                } header: {
                    Text(R.string.localizable.aboutSectionHeaderCredits().uppercased())
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
                        content: {})
                }
            }
            .listStyle(.grouped)
            .navigationTitle(R.string.localizable.aboutTitle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbarBackground(.visible)
            .toolbarBackground(Color.fivecallsDarkBlue)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.dismiss()
                    }) {
                        Text(R.string.localizable.doneButtonTitle())
                            .bold()
                    }
                }
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

struct AboutSheet_Previews: PreviewProvider {
    static var previews: some View {
        AboutSheet()
    }
}
