//
//  LocationButton.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 3/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class LocationButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = tintColor.cgColor
        layer.borderWidth = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height/2
    }
    
    private var _highlited = false
    override var isHighlighted: Bool {
        get { return _highlited }
        set {
            _highlited = newValue
            backgroundColor = isHighlighted ? tintColor : .clear
            titleLabel?.textColor = isHighlighted ? .white : tintColor
        }
    }
}
