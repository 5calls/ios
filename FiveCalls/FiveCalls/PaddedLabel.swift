//
//  PaddedLabel.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class PaddedLabel : UILabel {

    @IBInspectable public var padding: CGFloat = 0 {
        didSet {
            contentInset = UIEdgeInsets(top: padding / 2.0, left: padding, bottom: padding / 2.0, right: padding)
        }
    }
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInset.left + contentInset.right, height: size.height + contentInset.top + contentInset.bottom)
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, contentInset)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -contentInset.top,
                                          left: -contentInset.left,
                                          bottom: -contentInset.bottom,
                                          right: -contentInset.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override public func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, contentInset))
    }

}
