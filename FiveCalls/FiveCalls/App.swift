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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
            
    let store = Store(state: AppState(), middlewares: [appMiddleware()])
    @AppStorage(UserDefaultsKey.hasShownWelcomeScreen.rawValue) var hasShownWelcomeScreen = false
    @State var showWelcomeScreen = false

    var body: some Scene {
        WindowGroup {
            IssueSplitView()
                .environmentObject(store)
                .sheet(isPresented: $showWelcomeScreen) {
                    Welcome().environmentObject(store)
                }
                .onAppear {
                    if !hasShownWelcomeScreen {
                        showWelcomeScreen = true
                    }
                }
        }
    }
}

