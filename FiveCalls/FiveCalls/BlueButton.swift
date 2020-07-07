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
    
    var normalBackgroundColor = R.color.lightBlueBackground()
    var highlightBackgroundColor: UIColor = R.color.darkBlue()!
    var selectedBackgroundColor: UIColor = R.color.darkBlue()!
    var defaultTextColor: UIColor = .white
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        _commonInit()
    }
    
    private func _commonInit() {
        updateColors()
        setTitle(titleLabel?.text?.capitalized, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: customFontSize)
        layer.cornerRadius = 5
        clipsToBounds = true
    }

    override var isHighlighted: Bool {
        didSet {
            updateColors()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            updateColors()
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateColors()
        }
    }
    
    func updateColors() {
        if isHighlighted { backgroundColor = highlightBackgroundColor }
        else if isSelected { backgroundColor = selectedBackgroundColor }
        else { backgroundColor = normalBackgroundColor }
        
        setTitleColor(.white, for: .selected)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(defaultTextColor, for: .normal)
        
        titleLabel?.alpha = 1.0
        alpha = isEnabled ? 1.0 : 0.5
    }
}
