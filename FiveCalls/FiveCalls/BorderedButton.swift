//
//  BorderedButton.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton : UIButton {
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var allBorders: Bool {
        get {
            return leftBorder && topBorder && rightBorder && bottomBorder
        }
        set {
            leftBorder = newValue
            topBorder = newValue
            rightBorder = newValue
            leftBorder = newValue
        }
    }
    
    @IBInspectable
    var leftBorder: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var topBorder: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var rightBorder: Bool = false{
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var bottomBorder: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard borderWidth > 0 else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineWidth(borderWidth)
        context.setStrokeColor(borderColor.cgColor)
        
        let topLeft = CGPoint.zero
        let bottomLeft = CGPoint(x: 0, y: bounds.size.height)
        let topRight = CGPoint(x: bounds.size.width, y: 0)
        let bottomRight = CGPoint(x: bounds.size.width, y: bounds.size.height)
            
        if leftBorder {
            context.move(to: topLeft)
            context.addLine(to: bottomLeft)
        }
        
        if topBorder {
            context.move(to: topLeft)
            context.addLine(to: topRight)
        }
        
        if rightBorder {
            context.move(to: topRight)
            context.addLine(to: bottomRight)
        }
        
        if bottomBorder {
            context.move(to: bottomLeft)
            context.addLine(to: bottomRight)
        }
        
        context.strokePath()
    }
}
