//
//  BlueButton.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class BlueButton: UIButton {
    
    @IBInspectable
    var customFontSize: CGFloat = 20 {
        didSet {
            _commonInit()
        }
    }
    
    var normalBackgroundColor = UIColor(colorLiteralRed:0.73, green:0.87, blue:0.98, alpha:1.0)
    var highlightBackgroundColor = UIColor(colorLiteralRed:0.90, green:0.22, blue:0.21, alpha:1.0)
    var defaultTextColor = UIColor(colorLiteralRed:0.09, green:0.46, blue:0.82, alpha:1.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        _commonInit()
    }
    
    private func _commonInit() {
        updateColors()
        setTitle(titleLabel?.text?.uppercased(), for: .normal)
        
        if let fontDescriptor = UIFontDescriptor(fontAttributes: [
                    UIFontDescriptorFamilyAttribute: "Roboto Condensed"
                    ]).withSymbolicTraits([.traitBold, .traitCondensed]) {
            titleLabel?.font = UIFont(descriptor: fontDescriptor, size: customFontSize)
        }
        
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
        setTitleColor(.white, for: .selected)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(defaultTextColor, for: .normal)
    }
}
