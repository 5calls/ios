// Copyright 5calls. All rights reserved. See LICENSE for details.

import Foundation
import OneSignalExtension
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        receivedRequest = request
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent {
            OneSignalExtension.didReceiveNotificationExtensionRequest(receivedRequest, with: bestAttemptContent, withContentHandler: contentHandler)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler, let bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
}
