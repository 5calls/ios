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
                    AboutListItem(title: R.string.localizableR.aboutItemWhyCall(),
                                  type: .action({
                        openSocialLink("https://5calls.org/why-calling-works/")
                    }))
                    AboutListItem(title: R.string.localizableR.aboutItemWhoWeAre(),
                                  type: .action({
                        openSocialLink("https://5calls.org/about-us/")
                    }))
                    AboutListItem(title: R.string.localizableR.aboutItemFeedback(),
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
                        Alert(title: Text(R.string.localizableR.cantSendEmailTitle()),
                              message: Text(R.string.localizableR.cantSendEmailMessage()),
                              dismissButton: .default(Text(R.string.localizableR.dismissTitle())))
                    }
                    AboutListItem(title: R.string.localizableR.aboutItemShowWelcome(),
                                  type: .action({
                        showWelcome = true
                    }))
                    .sheet(isPresented: $showWelcome, content: {
                        Welcome()
                    })
                } header: {
                    Text(R.string.localizableR.aboutSectionHeaderGeneral().uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    TextField(R.string.localizableR.aboutCallingGroupPlaceholder(), text: $callingGroup)
                        .onChange(of: callingGroup) { newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                            if trimmed != newValue {
                                callingGroup = trimmed
                            }
                            UserDefaults.standard.set(trimmed, forKey: UserDefaultsKey.callingGroup.rawValue)
                        }
                } header: {
                    Text(R.string.localizableR.aboutCallingGroupHeader().uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text(R.string.localizableR.aboutCallingGroupFooter())
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
                        AboutListItem(title: R.string.localizableR.aboutItemShare(),
                                      type: .url(appUrl!))
                    }
                    AboutListItem(title: R.string.localizableR.aboutItemRate(),
                                  type: .action({
                        requestReview()
                    }))
                } header: {
                    Text(R.string.localizableR.aboutSectionHeaderSocial().uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text(R.string.localizableR.aboutSectionFooterSocial())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    AboutListItem(title: R.string.localizableR.aboutItemOpenSource(),
                                  type: .acknowledgements)
                } header: {
                    Text(R.string.localizableR.aboutSectionHeaderCredits().uppercased())
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
            .navigationTitle(R.string.localizableR.aboutTitle())
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
                        Text(R.string.localizableR.doneButtonTitle())
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

struct AboutSheet_Previews: PreviewProvider {
    static var previews: some View {
        AboutSheet()
    }
}
