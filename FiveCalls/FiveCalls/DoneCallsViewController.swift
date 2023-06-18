//
//  DoneCallsViewController.swift
//  FiveCalls
//
//  Created by Nick O'Neill on 1/21/20.
//  Copyright © 2020 5calls. All rights reserved.
//

import UIKit
import StoreKit
import OneSignal

class DoneCallsViewController: UIViewController, IssueShareable {
    var issue: Issue!
    var contacts: [Contact]!
    var flowLogs: [ContactLog]!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var ratingPromptCounter: RatingPromptCounter = {
        return RatingPromptCounter(handler: { SKStoreReviewController.requestReview() })
    }()
    
    var totalCalls = 0
    var issueCalls = 0
    let callCountFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 20
        tableView.sectionFooterHeight = 0

        self.navigationItem.title = R.string.localizable.doneScreenTitle()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: R.string.localizable.doneScreenButton(), style: .done, target: self, action: #selector(backToList)), animated: false)
        
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
        
        // these two should never show at the same time, rating will always
        // wait until 5, notifications will trigger on the first one.
        ratingPromptCounter.increment()
        checkForNotifications()
    }
    
    @objc func backToList() {
        self.performSegue(withIdentifier: R.segue.doneCallsViewController.unwindToIssueList.identifier, sender: nil)
    }
    
    @IBAction func share() {
        shareIssue(from: nil)
    }
    
    func showsDonationSection() -> Bool {
        let logs = ContactLogs.load()
        if logs.all.count > 6 {
            return true
        }

        return false
    }
}

extension DoneCallsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.contacts.count
        case 1:
            return 2 // number of progress bars
        case 2:
            if showsDonationSection() {
                return 1 // donate
            }
            return 0
        case 3:
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
                cell.progressTitle.text = R.string.localizable.totalCalls()
                cell.progress.progress = Float(self.totalCalls) / Float(self.totalCalls).progressStep()
                cell.progressLabel.text = String(format: "%ld %@", locale: Locale.current, self.totalCalls, R.string.localizable.calls())
            case 1:
                cell.progressTitle.text = R.string.localizable.totalIssueCalls()
                cell.progress.progress = Float(self.issueCalls) / Float(self.issueCalls).progressStep()
                cell.progressLabel.text = String(format: "%ld %@", locale: Locale.current, self.issueCalls, R.string.localizable.calls())
            default:
                break
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.donateCell, for: indexPath)!
            cell.configure()
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shareCell, for: indexPath)!
            cell.configure(issue: self.issue)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension DoneCallsViewController {
    func checkForNotifications() {
        let deviceState = OneSignal.getDeviceState()
        let nextPrompt = nextNotificationPromptDate() ?? Date()
                
        if deviceState?.hasNotificationPermission == false && nextPrompt <= Date() {
            let alert = UIAlertController(title: R.string.localizable.notificationTitle(), message: R.string.localizable.notificationAsk(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.notificationImportant(), style: .default, handler: { (action) in
                OneSignal.promptForPushNotifications(userResponse: { (success) in
                    //
                })
            }))
            alert.addAction(UIAlertAction(title: R.string.localizable.notificationNone(), style: .cancel, handler: { (action) in
                let key = UserDefaultsKey.lastAskedForNotificationPermission.rawValue
                UserDefaults.standard.set(Date(), forKey: key)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func nextNotificationPromptDate() -> Date? {
        let key = UserDefaultsKey.lastAskedForNotificationPermission.rawValue
        guard let lastPrompt = UserDefaults.standard.object(forKey: key) as? Date else { return nil }
        
        return Calendar.current.date(byAdding: .month, value: 1, to: lastPrompt)
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
        } else if self < 90000 {
            return 100000
        } else if self < 450000 {
            return 500000
        } else if self < 900000 {
            return 1000000
        } else if self < 4500000 {
            return 5000000
        }
        
        return 0
    }
}
