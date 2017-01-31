//
//  IssuesViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class IssuesViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        fetchIssues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if let zip = UserDefaults.standard.string(forKey: UserDefaultsKeys.zipCode.rawValue) {
//            
//        }
    }
    
    private func fetchIssues() {
        let operation = FetchIssuesOperation(zipCode: nil)
        operation.completionBlock = { [weak self] in
            print("Issues: \(operation.issuesList)")
        }
        OperationQueue.main.addOperation(operation)
    }
}
