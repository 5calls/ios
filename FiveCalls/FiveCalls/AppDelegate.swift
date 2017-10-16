//
//  AppDelegate.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Pantry
import Fabric
import Crashlytics
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if isUITesting() {
            resetData()
        }

        BuddyBuildSDK.setup()
        Fabric.with([Crashlytics.self])

        migrateSavedData()
        
        
        Pantry.useApplicationSupportDirectory = true

        clearNotificationBadge()
        setAppearance()

        resetOrInitializeCountForRating()
        
        if !UserDefaults.standard.bool(forKey: UserDefaultsKey.hasShownWelcomeScreen.rawValue) {
            showWelcome()
        }

        oneSignalStartup(launchOptions: launchOptions)

        return true
    }

    func oneSignalStartup(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "5fd4ca41-9f6c-4149-a312-ae3e71b35c0e",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
    }

    func migrateSavedData() {
        let pantryDirName = "com.thatthinginswift.pantry"
        // Pantry used to store data in the caches folder. If this exists, we need to move it
        // and delete it, to avoid this getting purged when the device is low on disk space.
        let cachesDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let oldPantryPath = URL(fileURLWithPath: cachesDir).appendingPathComponent(pantryDirName).path

        if FileManager.default.fileExists(atPath: oldPantryPath) {
            print("Saved data found in caches folder, moving to Application Support...")
            let appSupportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
            let targetPath = URL(fileURLWithPath: appSupportDir).appendingPathComponent(pantryDirName).path
            do {
                try FileManager.default.moveItem(atPath: oldPantryPath, toPath: targetPath)
                print("Files migrated.")
            } catch let e {
                print("Error moving files: \(e)")
            }
        }
    }
    
    func transitionTo(rootViewController viewController: UIViewController) {
        guard let window = self.window else { return }
        guard window.rootViewController != viewController else { return }
        
        let snapshot = window.snapshotView(afterScreenUpdates: false)!
        viewController.view.addSubview(snapshot)
        window.rootViewController = viewController
        
        UIView.animate(withDuration: 0.5, animations: {
            snapshot.alpha = 0
            snapshot.frame.origin.y += window.frame.size.height
            snapshot.transform = snapshot.transform.scaledBy(x: 0.8, y: 0.8)
        }) { completed in
            snapshot.removeFromSuperview()
        }
    }
    
    func showWelcome() {
        guard let window = self.window else { return }
        let welcomeVC = R.storyboard.welcome.welcomeViewController()!
        let mainVC = window.rootViewController!
        welcomeVC.completionBlock = {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasShownWelcomeScreen.rawValue)
            self.transitionTo(rootViewController: mainVC)
        }
        window.rootViewController = welcomeVC
    }
    
    func setAppearance() {
        Appearance.instance.setup()
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
        Pantry.removeAllCache()
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
}
