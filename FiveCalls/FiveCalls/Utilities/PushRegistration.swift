// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation
import UIKit
import UserNotifications

/// Owns the app's side of push notifications now that OneSignal doesn't.
///
/// The APNs device token belongs to us, not to any vendor, so all this does is
/// ask iOS for one and hand it to the 5calls API along with the caller's
/// district. Registration is an upsert on the token, so re-sending it is
/// harmless and is how a token stays fresh as people reinstall or restore.
enum PushRegistration {
    private static var storedToken: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKey.pushToken.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.pushToken.rawValue) }
    }

    private static var storedDistrict: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKey.pushDistrict.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.pushDistrict.rawValue) }
    }

    /// Whether the user has already granted notification permission. Replaces
    /// OneSignal's getDeviceState().hasNotificationPermission.
    static func hasPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized ||
            settings.authorizationStatus == .provisional
    }

    /// Asks for notification permission and, if granted, registers with APNs.
    /// Replaces OneSignal.promptForPushNotifications.
    @discardableResult
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        let granted: Bool
        do {
            granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("notification permission request failed: \(error)")
            return false
        }

        if granted {
            await registerWithAPNs()
        }

        return granted
    }

    /// Registers with APNs if permission was granted at some point in the past.
    /// Safe to call on every launch: iOS hands back the current token, which is
    /// how we notice a token that changed while the app wasn't running.
    static func registerIfAuthorized() async {
        guard await hasPermission() else { return }
        await registerWithAPNs()
    }

    @MainActor
    private static func registerWithAPNs() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    /// Called by the app delegate when APNs hands us a device token.
    static func didRegister(deviceToken: Data) {
        // the API expects the token as hex, which is also the form OneSignal
        // stored it in, so imported tokens and new ones look the same
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        storedToken = token
        send(token: token)
    }

    static func didFailToRegister(error: Error) {
        print("APNs registration failed: \(error)")
    }

    /// Called when we learn the caller's district, so the API can target them.
    /// Only re-sends when the district actually changed and we have a token.
    static func update(district: String) {
        guard !district.isEmpty, district != "-" else { return }
        guard district != storedDistrict else { return }

        storedDistrict = district

        if let token = storedToken {
            send(token: token)
        }
    }

    /// Removes this device's token when someone turns notifications off.
    static func disable() {
        guard let token = storedToken else { return }

        OperationQueue.main.addOperation(UnregisterPushTokenOperation(token: token))
        storedToken = nil
    }

    private static func send(token: String) {
        let operation = RegisterPushTokenOperation(token: token, district: storedDistrict)
        OperationQueue.main.addOperation(operation)
    }
}
