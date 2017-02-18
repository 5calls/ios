//
//  UIView+FiveCalls.swift
//  FiveCalls
//
//  Created by Ellen Shapiro on 2/13/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

extension UIView {

    func fvc_circleify() {
        guard frame.width == frame.height else {
            assertionFailure("This isn't gonna turn into a circle if the height and width are different.")
            return
        }
        
        clipsToBounds = true
        layer.cornerRadius = frame.width / 2
    }

}
