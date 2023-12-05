//
//  AboutSheet.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/18/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import StoreKit

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
                    AboutListItem(title: R.string.localizable.aboutItemWhyCall(), navigationLinkValue: WebViewContent.whycall)
                    AboutListItem(title: R.string.localizable.aboutItemWhoWeAre(), navigationLinkValue: WebViewContent.whoweare)
                    .navigationDestination(for: WebViewContent.self) { webViewContent in
                        WebView(webViewContent: webViewContent)
                            .navigationTitle(webViewContent.navigationTitle)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbarBackground(.visible)
                            .toolbarBackground(Color.fivecallsDarkBlue)
                            .toolbarColorScheme(.dark, for: .navigationBar)
                    }
                    AboutListItem(title: R.string.localizable.aboutItemFeedback()) {
                        if EmailComposerView.canSendEmail() {
                            showEmailComposer = true
                        } else {
                            showEmailComposerAlert = true
                        }
                    }
                    .sheet(isPresented: $showEmailComposer){
                        EmailComposerView() { _ in }
                    }
                    .alert(isPresented: $showEmailComposerAlert) {
                        Alert(title: Text(R.string.localizable.cantSendEmailTitle()),
                              message: Text(R.string.localizable.cantSendEmailMessage()),
                              dismissButton: .default(Text(R.string.localizable.dismissTitle())))
                    }
                    AboutListItem(title: R.string.localizable.aboutItemShowWelcome()) {
                        showWelcome = true
                    }
                    .sheet(isPresented: $showWelcome, content: {
                        Welcome()
                    })
                } header: {
                    Text(R.string.localizable.aboutSectionHeaderGeneral())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    AboutListItem(title: R.string.localizable.aboutItemFollowTwitter()) {
                        followOnTwitter()
                    }
                    if appUrl != nil {
                        AboutListItem(title: R.string.localizable.aboutItemShare(), url: appUrl)
                    }
                    AboutListItem(title: R.string.localizable.aboutItemRate()) {
                        requestReview()
                    }
                } header: {
                    Text(R.string.localizable.aboutSectionHeaderSocial())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text(R.string.localizable.aboutSectionFooterSocial())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
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
    
    func followOnTwitter() {
        guard let url = URL(string: "https://twitter.com/make5calls") else { return }
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
