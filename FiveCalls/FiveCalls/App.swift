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
    @State var welcomePresented = false

    var body: some Scene {
        WindowGroup {
            IssueSplitView()
                .environmentObject(store)
                .sheet(isPresented: $welcomePresented) {
                    Welcome().environmentObject(store)
                }
                .onAppear {
                    if !hasShownWelcomeScreen {
                        welcomePresented = true
                        hasShownWelcomeScreen = true
                    }
                }
        }
    }
}

