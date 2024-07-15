//
//  App.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 6/28/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI

@main
struct FiveCallsApp: App {
    @StateObject var store: Store = Store(state: AppState(), middlewares: [appMiddleware()])
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
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        if store.state.needsIssueRefresh {
                            store.dispatch(action: .FetchIssues)
                        }
                    }
                }
        }
    }
}

