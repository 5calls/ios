//
//  ContactCell.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/3/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class ContactCell : UITableViewCell {
    
    var progressView: ProgressView!
    
    var hasContacted: Bool = false {
        didSet {
            progressView.progress = hasContacted ? 1.0 : 0.0
        }
    }
    
    var borderTop = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc var separatorColor: UIColor = .lightGray
    var labelTextColor = R.color.darkGray()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView = ProgressView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        accessoryView = progressView
        
        textLabel?.textColor = labelTextColor
        detailTextLabel?.textColor = labelTextColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
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
    
    func configure(contact: Contact, hasContacted: Bool) {
        self.nameLabel.text = contact.name
        self.subtitleLabel.text = contact.area
        if let photoURL = contact.photoURL {
            self.avatarImageView.setImageFromURL(photoURL)
        } else {
            self.avatarImageView.image = UIImage(named: "icon-office")
        }
        self.hasContacted = hasContacted
    }
}
