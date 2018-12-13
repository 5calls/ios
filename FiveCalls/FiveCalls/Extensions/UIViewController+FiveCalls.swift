//
//  UIViewController+FiveCalls.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 12/12/18.
//  Copyright © 2018 5calls. All rights reserved.
//

import UIKit
import Mixpanel

extension UIViewController {
    func trackEvent(_ name: String, properties: [String: String]? = nil) {
        Mixpanel.sharedInstance()?.track(name, properties: properties)
    }
}
