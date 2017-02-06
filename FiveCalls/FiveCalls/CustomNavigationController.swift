//
//  CustomNavigationController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class CustomNavigationController : UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}

extension UINavigationController  {
    func replaceTopViewController(with newViewController: UIViewController, animated: Bool) {
        var controllers = viewControllers
        let newIndex = viewControllers.count - 1
        controllers[newIndex] = newViewController
        setViewControllers(controllers, animated: animated)
    }
}
