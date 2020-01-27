//
//  DoneCallsViewController.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 1/21/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import UIKit

class DoneCallsViewController: UIViewController {
    var issue: Issue!
    var contacts: [Contact]!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(backToList)), animated: false)
        
        // get total call #
        // get issue call #
    }
    
    @objc func backToList() {
        self.performSegue(withIdentifier: R.segue.doneCallsViewController.unwindToIssueList.identifier, sender: nil)
    }
}

extension DoneCallsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3 // number of contacts
        case 1:
            return 2 // number of progress bars
        case 2:
            return 1 // share
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contactCell, for: indexPath)!
            cell.configure(contact: self.contacts[indexPath.row], hasContacted: true)
            cell.borderTop = indexPath.row == 0
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.progressCell, for: indexPath)!
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shareCell, for: indexPath)!
            cell.configure(issue: self.issue)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
