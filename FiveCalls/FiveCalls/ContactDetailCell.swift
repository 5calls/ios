//
//  ContactDetailCell.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/3/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class ContactDetailCell : UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callingReasonLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
    }
    
}
