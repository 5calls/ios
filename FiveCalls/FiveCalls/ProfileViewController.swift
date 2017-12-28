//
//  ProfileViewController.swift
//  FiveCalls
//
//  Created by Melville Stanley on 12/27/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class ProfileViewController : UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = SessionManager.shared.userProfile {
            if (user.picture != nil) {
                profilePic.kf.setImage(with: user.picture)
            } else {
                profilePic.image = UIImage(named: "profile")
            }
            name.text = user.name
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        SessionManager.shared.stopSession()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

