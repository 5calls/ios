//
//  Appearance.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/22/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

enum Appearance {
    static func setup() {
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = R.color.lightBlue()
        pageControlAppearance.currentPageIndicatorTintColor = R.color.darkBlue()
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.fvc_header
        ]
    }
    
    static func swiftUISetup() {
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.backward.circle.fill")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.backward.circle.fill")
    }
}
