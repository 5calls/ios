//
//  IssueDetailViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class IssueDetailViewController : UIViewController {
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
