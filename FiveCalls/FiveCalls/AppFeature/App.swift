// Copyright 5calls. All rights reserved. See LICENSE for details.

import SwiftUI

@main
struct FiveCallsApp: App {
    @StateObject var store: Store = .init(state: AppState(), middlewares: [appMiddleware()])
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(UserDefaultsKey.hasShownWelcomeScreen.rawValue) var hasShownWelcomeScreen = false

    var body: some Scene {
        WindowGroup {
            IssueSplitView()
                .environmentObject(store)
                .sheet(isPresented: $store.state.showWelcomeScreen) {
                    Welcome().environmentObject(store)
                }
                .onAppear {
                    appDelegate.app = self
                    if !hasShownWelcomeScreen {
                        store.dispatch(action: .ShowWelcomeScreen)
                    }
                }
                .onOpenURL { url in
                    // universal links arrive here rather than the app delegate
                    // in a SwiftUI app. Dashboard handles navigating to the issue.
                    if let referral = PostReferralOperation.forLink(url) {
                        OperationQueue.main.addOperation(referral)
                    }
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        if store.state.needsIssueRefresh {
                            store.dispatch(action: .FetchIssues)
                        }
                    }
                }
        }
    }
}
