//
//  EllipsisButton.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class EllipsisButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        fvc_circleify()
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
    }
}
