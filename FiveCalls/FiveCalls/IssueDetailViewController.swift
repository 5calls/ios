//
//  IssueDetailViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation
import Crashlytics

class IssueDetailViewController : UIViewController, IssueShareable {
    
    fileprivate let multipleDistrictText = "Your ZIP code contains more than one congressional district. Please select “Use My Location” to locate your representative."
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    var logs: ContactLogs?
    
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(IssueDetailViewController.shareButtonPressed(_ :)))
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Answers.logCustomEvent(withName:"Screen: Issue Detail", customAttributes: ["issue_id":issue.id])
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        logs = ContactLogs.load()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController,
            let loc = nav.viewControllers.first as? EditLocationViewController {
            loc.delegate = self
        } else if let call = segue.destination as? CallScriptViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            call.issuesManager = issuesManager
            call.issue = issue
            call.contact = issue.contacts[indexPath.row]
        }        
    }
    
    func shareButtonPressed(_ button: UIBarButtonItem) {
        shareIssue()
    }
}

enum IssueSections : Int {
    case header
    case contacts
    case count
}

enum IssueHeaderRows : Int {
    case title
    case description
    case count
}

extension IssueDetailViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return IssueSections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == IssueSections.header.rawValue {
            return IssueHeaderRows.count.rawValue
        } else {
            return max(1, issue.contacts.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case IssueSections.header.rawValue:
            return headerCell(at: indexPath)
        default:
            if issue.contacts.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.setLocationCell, for: indexPath)! as SetLocationCell
                if issuesManager.isSplitDistrict {
                    cell.messageLabel.text = multipleDistrictText
                } else {
                    cell.messageLabel.text = "Set your location to find your representatives"
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contactCell, for: indexPath)!
                cell.borderTop = indexPath.row == 0
                let contact = issue.contacts[indexPath.row]
                cell.nameLabel.text = contact.name
                cell.subtitleLabel.text = contact.area
                if let photoURL = contact.photoURL {
                    cell.avatarImageView.setRemoteImage(url: photoURL)
                } else {
                    cell.avatarImageView.image = cell.avatarImageView.defaultImage
                }
                if let hasContacted = logs?.hasContacted(contactId: contact.id, forIssue: issue.id) {
                    cell.hasContacted = hasContacted
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !issue.contacts.isEmpty && section == IssueSections.contacts.rawValue {
            return "Call your representatives"
        }
        return nil
    }
    
    private func headerCell(at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case IssueHeaderRows.title.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! IssueDetailCell
            cell.issueLabel.text = issue.name
            return cell
            
        case IssueHeaderRows.description.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! IssueDetailCell
            cell.issueLabel.text = issue.reason
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func scrollToBottom() {
        let s = self.tableView.contentSize
        var b = self.tableView.bounds
        b.origin.y = max(0,s.height - b.height)
        self.tableView.scrollRectToVisible(b, animated: true)
    }
}

extension IssueDetailViewController : EditLocationViewControllerDelegate {
    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func editLocationViewController(_ vc: EditLocationViewController, didUpdateLocation location: UserLocation) {
        issuesManager.userLocation = location
        issuesManager.fetchIssues {
            
            if self.issuesManager.isSplitDistrict {
                let alertController = UIAlertController(title: "Split Congressional District", message:
                    self.multipleDistrictText, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                vc.present(alertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        
            
            if let issue = self.issuesManager.issue(withId: self.issue.id) {
                self.issue = issue
                self.tableView.reloadSections([IssueSections.contacts.rawValue], with: .automatic)
                self.scrollToBottom()
            } else {
                // weird state to be in, but the issue we're looking at
                // no longer exists, so we'll just quietly (read: not quietly) 
                // pop back to the issues list
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
