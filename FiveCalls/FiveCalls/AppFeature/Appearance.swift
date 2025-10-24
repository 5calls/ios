// Copyright 5calls. All rights reserved. See LICENSE for details.

import UIKit

enum Appearance {
    static func swiftUISetup() {
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = .fivecallsLightBlue
        pageControlAppearance.currentPageIndicatorTintColor = .fivecallsDarkBlue
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.backward.circle.fill")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.backward.circle.fill")
        UIDatePicker.appearance().minuteInterval = 10
        UIDatePicker.appearance().roundsToMinuteInterval = true
    }
}
