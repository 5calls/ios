//
//  IssueDetailViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation

class IssueDetailViewController : UIViewController {
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "setLocationCell", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
                cell.borderTop = indexPath.row == 0
                let contact = issue.contacts[indexPath.row]
                cell.nameLabel.text = contact.name
                cell.subtitleLabel.text = contact.area
                if let photoURL = contact.photoURL {
                    cell.avatarImageView.setRemoteImage(url: photoURL)
                } else {
                    cell.avatarImageView.image = cell.avatarImageView.defaultImage
                }
                // This wont work while issue is a struct unless you return to root
                cell.hasContacted = contact.hasContacted
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == IssueSections.contacts.rawValue {
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
        let lastIndexPath = IndexPath(row: issue.contacts.count - 1, section: IssueSections.contacts.rawValue)
        self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
}

extension IssueDetailViewController : EditLocationViewControllerDelegate {
    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func editLocationViewController(_ vc: EditLocationViewController, didUpdateLocation location: UserLocation) {
        issuesManager.userLocation = location
        issuesManager.fetchIssues {
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
        dismiss(animated: true, completion: nil)
        
    }
}
