//
//  UINavigationController+SwipeBack.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 10/8/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import UIKit

// we want to opt out of the default title / back behavior but simply using .navigationBarHidden(true)
// disables the swipe back gesture which is natural on iOS. This renables it.
// TODO: this also impacts UIKit by virtue of being an extension, but is not tested there
extension UINavigationController: UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
