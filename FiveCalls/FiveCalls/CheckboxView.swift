//
//  CheckboxView.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class CheckboxView : UIView {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    private func _commonInit() {
        isOpaque = false
        backgroundColor = .clear
        
        let image = R.image.iconCheckmark()
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = !isChecked
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 26),
            imageView.heightAnchor.constraint(equalToConstant: 19)
        ])
    }
    
    override func prepareForInterfaceBuilder() {
        imageView.image = UIImage(resource: R.image.iconCheckmark, compatibleWith: nil)
    }
    
    @IBInspectable var borderColor: UIColor = .fvc_lightGray {
        didSet {
             setNeedsDisplay()
        }
    }
    @IBInspectable var selectedBackgroundColor: UIColor = .fvc_green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var isChecked: Bool = false {
        didSet {
            imageView.isHidden = !isChecked
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(bounds)
        
        let r = bounds.insetBy(dx: 2, dy: 2)
        
        if isChecked {
            context?.setFillColor(selectedBackgroundColor.cgColor)
            context?.fillEllipse(in: r)
            
        } else {
            context?.setLineWidth(3)
            context?.setStrokeColor(borderColor.cgColor)
            context?.strokeEllipse(in: r)
        }
    }
}
