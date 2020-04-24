//
//  DonateCell.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 1/31/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import UIKit

class DonateCell: UITableViewCell {
    let donateURL = URL(string: "https://secure.actblue.com/donate/5calls-donate?refcode=ios")!
    @IBOutlet var donateButton: UIButton!
    
    func configure() {
        self.donateButton.layer.cornerRadius = 10
    }
    
    @IBAction func donate() {
        UIApplication.shared.open(donateURL)
    }
}
