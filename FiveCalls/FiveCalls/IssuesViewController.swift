//
//  IssuesViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class IssuesViewController : UITableViewController {
    
    var issues: [Issue]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // edgesForExtendedLayout = []
        navigationController?.setNavigationBarHidden(true, animated: false)
        let zip = UserDefaults.standard.string(forKey: UserDefaultsKeys.zipCode.rawValue)
        fetchIssues(forZip: zip)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(zipCodeChanged(_:)), name: .zipCodeChanged, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func zipCodeChanged(_ notif: Notification) {
        let zip = UserDefaults.standard.string(forKey: UserDefaultsKeys.zipCode.rawValue)
        fetchIssues(forZip: zip)
    }

    private func fetchIssues(forZip zip: String?) {
        let operation = FetchIssuesOperation(zipCode: zip)
        operation.completionBlock = { [weak self] in
            if let issues = operation.issuesList?.issues {
                self?.issues = issues
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        OperationQueue.main.addOperation(operation)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issues?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IssueCell") as! IssueCell
        if let issue = issues?[indexPath.row] {
            cell.titleLabel.text = issue.name
        }
        return cell
    }
}
