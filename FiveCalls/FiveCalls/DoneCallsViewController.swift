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
    var flowLogs: [ContactLog]!
    @IBOutlet weak var tableView: UITableView!
    
    var totalCalls = 0
    var issueCalls = 0
    let callCountFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(backToList)), animated: false)
        
        let callcountOp = FetchStatsOperation()
        callcountOp.issueID = String(issue.id)
        callcountOp.completionBlock = {
            self.totalCalls = callcountOp.numberOfCalls ?? 0
            self.issueCalls = callcountOp.numberOfIssueCalls ?? 0
            DispatchQueue.main.async {
                self.tableView.reloadSections([1], with: .automatic)
            }
        }
        OperationQueue.main.addOperation(callcountOp)

        // • tap to share
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
            return self.contacts.count
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
            
            let contact = self.contacts[indexPath.row]
            cell.configure(contact: contact, hasContacted: true)
            cell.borderTop = indexPath.row == 0
            
            // find latest result in log for rep
            if let result = self.flowLogs.first(where: { $0.contactId == contact.id}) {
                cell.subtitleLabel.text = result.localizedOutcome
            } else {
                cell.subtitleLabel.text =  R.string.localizable.outcomesSkip()
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.progressCell, for: indexPath)!
            
            switch indexPath.row {
            case 0:
                cell.progressTitle.text = "Total Calls"
                cell.progress.progress = Float(self.totalCalls) / 5000000
                cell.progressLabel.text = String(format: "%ld %@", locale: Locale.current, self.totalCalls, "Calls")
            case 1:
                cell.progressTitle.text = "Calls on this topic"
                cell.progress.progress = Float(self.issueCalls) / Float(self.issueCalls).progressStep()
                cell.progressLabel.text = String(format: "%ld %@", locale: Locale.current, self.issueCalls, "Calls")
            default:
                break
            }
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

extension Float {
    func progressStep() -> Float {
        if self < 80 {
            return 100
        } else if self < 450 {
            return 500
        } else if self < 900 {
            return 1000
        } else if self < 4500 {
            return 5000
        } else if self < 9000 {
            return 10000
        } else if self < 45000 {
            return 50000
        }
        
        return 0
    }
}
