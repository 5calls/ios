//
//  ShareCell.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 1/26/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import UIKit

class ShareCell: UITableViewCell {
    @IBOutlet weak var shareImage: UIImageView!
    
    func configure(issue: Issue) {
        self.shareImage.setImageFromURL(issue.shareImageURL)
    }
}
