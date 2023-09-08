//
//  UIAlertViewController+FiveCalls.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func settingsAlertView(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: .alert)
        let dismiss = UIAlertAction(title: R.string.localizable.dismissTitle(), style: .default ,handler: nil)
        alertController.addAction(dismiss)
        let openSettings = UIAlertAction(title: R.string.localizable.openSettingsTitle(), style: .default, handler: { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        alertController.addAction(openSettings)
        alertController.preferredAction = openSettings
        return alertController
    }
}
