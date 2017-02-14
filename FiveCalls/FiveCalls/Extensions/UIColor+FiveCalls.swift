//
//  UIColor+FiveCalls.swift
//  FiveCalls
//
//  Created by Ellen Shapiro on 2/13/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

// Copy and paste into a playground to be able to see all colors. 
extension UIColor {

    //MARK: - Blues
    
    static let fvc_lightBlue = UIColor(red:0.68,
                                       green:0.82,
                                       blue:0.92,
                                       alpha:1.00)

    static let fvc_lightBlueBackground = UIColor(red:0.73,
                                                 green:0.87,
                                                 blue:0.98,
                                                 alpha:1.0)
    
    static let fvc_darkBlue = UIColor(red:0.12,
                                      green:0.47,
                                      blue:0.81,
                                      alpha:1.00)
    
    static let fvc_darkBlueText = UIColor(colorLiteralRed:0.09,
                                          green:0.46,
                                          blue:0.82,
                                          alpha:1.0)
    
    
    //MARK - Grays
    
    convenience init(fvc_gray component: Float) {
        self.init(colorLiteralRed: component,
                  green: component,
                  blue: component,
                  alpha: 1.00)
    }
    
    static let fvc_superLightGray = UIColor(fvc_gray: 0.96)
    
    static let fvc_lightGray = UIColor(fvc_gray: 0.90)
    
    static let fvc_mediumGray = UIColor(fvc_gray:0.88)
    
    //MARK: - Other colors
    
    static let fvc_red = UIColor(red:0.90,
                                 green:0.22,
                                 blue:0.21,
                                 alpha:1.00)
    
    static let fvc_green = UIColor(red:0.00,
                                   green:0.62,
                                   blue:0.36,
                                   alpha:1.00)
}
