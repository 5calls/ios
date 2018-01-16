//
//  ProfileCard.swift
//  FiveCalls
//
//  Created by Melville Stanley on 1/16/18.
//  Copyright © 2018 5calls. All rights reserved.
//

import UIKit

@IBDesignable
class ProfileCard : UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 1.2
    }
    
}
