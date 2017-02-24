//
//  ContactDetailCell.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/3/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class ContactDetailCell : UITableViewCell {
    
    @IBOutlet weak var avatarImageView: RemoteImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var callingReasonLabel: UILabel!
    @IBOutlet weak var moreNumbersButton: EllipsisButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImageView.fvc_circleify()
    }
    
}
