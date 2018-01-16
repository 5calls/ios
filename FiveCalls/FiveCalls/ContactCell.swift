//
//  ContactCell.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/3/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Kingfisher

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
    
    @objc var separatorColor: UIColor = .lightGray
    var labelTextColor: UIColor = .fvc_darkGray
    
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

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.fvc_circleify()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.setLineWidth(2)
        context?.setStrokeColor(separatorColor.cgColor)
        
        if borderTop {
            context?.move(to: .zero)
            context?.addLine(to: CGPoint(x: bounds.size.width, y: 0))
        }
        
        context?.move(to: CGPoint(x: 0, y: bounds.size.height))
        context?.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
        
        context?.strokePath()
    }
}
