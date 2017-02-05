//
//  ContactButton.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class ContactButton: UIButton {
    
    var normalBackgroundColor = UIColor(colorLiteralRed:0.73, green:0.87, blue:0.98, alpha:1.0)
    var highlightBackgroundColor = UIColor(colorLiteralRed:0.90, green:0.22, blue:0.21, alpha:1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
        layer.cornerRadius = 5
        clipsToBounds = true
    }

    override var isHighlighted: Bool {
        didSet {
            titleLabel?.alpha = 1.0
            updateColors()
        }
    }
    
    func updateColors() {
        backgroundColor = isHighlighted ? highlightBackgroundColor : normalBackgroundColor
    }
}
