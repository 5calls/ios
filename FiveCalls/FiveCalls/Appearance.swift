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
                UIFontDescriptor.AttributeName.family: fontFamily
                ]).withSymbolicTraits([.traitBold, .traitCondensed]) // To match the website, fonts should be Bold and Condensed
    }
    
    func setup() {
        let pageControlAppearance = UIPageControl.appearance()
        pageControlAppearance.pageIndicatorTintColor = .fvc_lightBlue
        pageControlAppearance.currentPageIndicatorTintColor = .fvc_darkBlue
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: headerFont
        ]
    }
    
    private func appFont(size: CGFloat, bold: Bool) -> UIFont! {
        if bold {
            return R.font.robotoCondensedBold(size: size)
        } else {
            return R.font.robotoCondensedRegular(size: size)
        }
    }
    
    var headerFont: UIFont {
        return appFont(size: 18, bold: true)
    }
    
    var bodyFont: UIFont {
        return appFont(size: 16, bold: false)
    }
}
