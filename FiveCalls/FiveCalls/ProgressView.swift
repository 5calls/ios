//
//  ProgressView.swift
//  FiveCalls
//
//  Created by Kyle Davis on 10/25/18.
//  Copyright © 2018 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressView : UIView {
    
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
        imageView.isHidden = (progress < 1.0)
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
    
    @IBInspectable var borderColor = R.color.fivecallsLightGray()! {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var selectedBackgroundColor = R.color.fivecallsGreen()! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var progress: Double = 0.0 {
        didSet {
            imageView.isHidden = (progress < 1.0)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.clear(bounds)
        
        let r = bounds.insetBy(dx: 2, dy: 2)
        
        if (progress >= 1.0) {
            context?.setFillColor(selectedBackgroundColor.cgColor)
            context?.fillEllipse(in: r)
            
        } else {
            context?.setLineWidth(3)
            context?.setStrokeColor(borderColor.cgColor)
            context?.strokeEllipse(in: r)
            
            let center = CGPoint(x: r.midX, y: r.midY)
            context?.addArc(center: center, radius: r.width / 2.0, startAngle: CGFloat(3.0 * .pi / 2.0), endAngle: CGFloat(2 * .pi * progress) + (3.0 * .pi / 2.0), clockwise: false)
            context?.setStrokeColor(R.color.fivecallsGreen()!.cgColor)
            context?.strokePath()
        }
    }
}
