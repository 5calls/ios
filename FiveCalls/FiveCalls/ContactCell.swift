//
//  ContactCell.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/3/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class ContactCell : UITableViewCell {
    
    var checkmarkView: CheckboxView!
    
    var hasContacted: Bool = false {
        didSet {
            checkmarkView.isChecked = hasContacted
        }
    }
    
    var borderTop = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var separatorColor: UIColor = .lightGray
    var labelTextColor: UIColor = UIColor(white: 0.4, alpha: 1)
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkView = CheckboxView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        accessoryView = checkmarkView
        
        textLabel?.textColor = labelTextColor
        detailTextLabel?.textColor = labelTextColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        print("imageView: \(imageView)")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(2)
        context?.setStrokeColor(separatorColor.cgColor)
        
        if borderTop {
            context?.move(to: CGPoint(x: 0, y: 0))
            context?.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        }
        
        context?.move(to: CGPoint(x: 0, y: bounds.size.height))
        context?.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        
        context?.strokePath()
    }
}
