//
//  Appearance.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/22/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class Appearance {
    
    static var instance = Appearance()
    
    var fontFamily: String {
        return "Roboto Condensed"
    }
    
    var fontDescriptor: UIFontDescriptor? {
        return UIFontDescriptor(fontAttributes: [
                UIFontDescriptorFamilyAttribute: fontFamily
                ]).withSymbolicTraits([.traitBold, .traitCondensed]) // To match the website, fonts should be Bold and Condensed
    }
    
    func setup() {
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = .fvc_lightBlue
        pageControlAppearance.currentPageIndicatorTintColor = .fvc_darkBlue
        
        // Fonts
        
        UINavigationBar.appearance().titleTextAttributes =
            [NSFontAttributeName: headerFont,
             NSForegroundColorAttributeName : UIColor.white]
        
        UINavigationBar.appearance().tintColor = .white
    }
    
    private func appFont(size: CGFloat, bold: Bool) -> UIFont! {
        if bold {
            return UIFont.boldSystemFont(ofSize: size)
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    var headerFont: UIFont {
        return appFont(size: 18, bold: true)
    }
    
    var bodyTitleFont: UIFont {
        return appFont(size: 16, bold: true)
    }
    
    var bodyFont: UIFont {
        return appFont(size: 16, bold: false)
    }
}
