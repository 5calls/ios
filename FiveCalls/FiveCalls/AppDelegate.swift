//
//  AppDelegate.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import SwiftUI
import OneSignal
import TipKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if isUITesting() {
            resetData()
        }

        clearNotificationBadge()
        setAppearance()

        resetOrInitializeCountForRating()
        
        oneSignalStartup(launchOptions: launchOptions)
        OneSignal.setExternalUserId(AnalyticsManager.shared.callerID)
        
        if #available(iOS 17.0, *) {
            try? Tips.configure()
        }
                    
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }
        
        return true
    }
    
    func oneSignalStartup(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let infoPlist = Bundle.main.infoDictionary, let oneSignalAppID = infoPlist["OneSignalAppID"] as? String {
            OneSignal.initWithLaunchOptions(launchOptions)
            OneSignal.setAppId(oneSignalAppID)
        }
    }
    
    func setAppearance() {
        Appearance.swiftUISetup()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    private func resetData() {
        // clear user defaults
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)

        // clear any saved location data
        ContactLogs.removeData()
    }
    
    private func clearNotificationBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private func resetOrInitializeCountForRating() {
        let defaults = UserDefaults.standard

        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }

        if let storedVersion = defaults.string(forKey: UserDefaultsKey.appVersion.rawValue),
            currentVersion == storedVersion {
            return
        }

        defaults.setValue(currentVersion, forKey: UserDefaultsKey.appVersion.rawValue)
        defaults.set(Int(0), forKey: UserDefaultsKey.countOfCallsForRatingPrompt.rawValue)
    }

    static var isRunningUnitTests: Bool {
        return ProcessInfo.processInfo.environment.keys.contains("XCInjectBundleInto")
    }
}
