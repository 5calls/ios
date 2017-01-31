//
//  AppDelegate.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setAppearance()
        
        if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasShownWelcomeScreen.rawValue) {
            showWelcome()
        }
        
        return true
    }
    
    func showWelcome() {
        guard let window = self.window else { return }
        let welcomeStoryboard = UIStoryboard(name: "Welcome", bundle: nil)
        let welcomeVC = welcomeStoryboard.instantiateInitialViewController()! as! WelcomeViewController
        let mainVC = window.rootViewController
        welcomeVC.completionBlock = {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasShownWelcomeScreen.rawValue)
            
            UIView.transition(with: window,
                              duration: 0.5,
                              options: [.transitionCurlUp],
                              animations: { 
                window.rootViewController = mainVC
            }, completion: nil)

        }
        window.rootViewController = welcomeVC
    }
    
    func setAppearance() {
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = UIColor(red:0.68, green:0.82, blue:0.92, alpha:1.00)
        pageControlAppearance.currentPageIndicatorTintColor = UIColor(red:0.12, green:0.47, blue:0.81, alpha:1.00)
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


}

