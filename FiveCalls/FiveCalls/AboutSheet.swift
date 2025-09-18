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
                    AboutListItem(title: Bundle.Strings.aboutItemWhyCall,
                                  type: .action({
                        openSocialLink("https://5calls.org/why-calling-works/")
                    }))
                    AboutListItem(title: Bundle.Strings.aboutItemWhoWeAre,
                                  type: .action({
                        openSocialLink("https://5calls.org/about-us/")
                    }))
                    AboutListItem(title: Bundle.Strings.aboutItemFeedback,
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
                        Alert(title: Text(Bundle.Strings.cantSendEmailTitle),
                              message: Text(Bundle.Strings.cantSendEmailMessage),
                              dismissButton: .default(Text(Bundle.Strings.dismissTitle)))
                    }
                    AboutListItem(title: Bundle.Strings.aboutItemShowWelcome,
                                  type: .action({
                        showWelcome = true
                    }))
                    .sheet(isPresented: $showWelcome, content: {
                        Welcome()
                    })
                } header: {
                    Text(Bundle.Strings.aboutSectionHeaderGeneral.uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    TextField(Bundle.Strings.aboutCallingGroupPlaceholder, text: $callingGroup)
                        .onChange(of: callingGroup) { newValue in
                            let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                            if trimmed != newValue {
                                callingGroup = trimmed
                            }
                            UserDefaults.standard.set(trimmed, forKey: UserDefaultsKey.callingGroup.rawValue)
                        }
                } header: {
                    Text(Bundle.Strings.aboutCallingGroupHeader.uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text(Bundle.Strings.aboutCallingGroupFooter)
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
                        AboutListItem(title: Bundle.Strings.aboutItemShare,
                                      type: .url(appUrl!))
                    }
                    AboutListItem(title: Bundle.Strings.aboutItemRate,
                                  type: .action({
                        requestReview()
                    }))
                } header: {
                    Text(Bundle.Strings.aboutSectionHeaderSocial.uppercased())
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                } footer: {
                    Text(Bundle.Strings.aboutSectionFooterSocial)
                        .font(.footnote)
                        .foregroundStyle(.fivecallsDarkGray)
                }

                Section {
                    AboutListItem(title: Bundle.Strings.aboutItemOpenSource,
                                  type: .acknowledgements)
                } header: {
                    Text(Bundle.Strings.aboutSectionHeaderCredits.uppercased())
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
            .navigationTitle(Bundle.Strings.aboutTitle)
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
                        Text(Bundle.Strings.doneButtonTitle)
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
