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
    var analyticsPath: String?
    
    func configure(withPath path: String) {
        self.donateButton.layer.cornerRadius = 10
        self.analyticsPath = path
    }
    
    @IBAction func donate() {
        if let path = analyticsPath {
            AnalyticsManager.shared.trackEvent(name: "donate", path: path)
        }
        UIApplication.shared.open(donateURL)
    }
}
