//
//  IssueDetailViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation
import Down

class IssueDetailViewController : UIViewController, IssueShareable {

    var issuesManager: IssuesManager!
    var issue: Issue!
    var logs: ContactLogs?
    var contacts: [Contact]?
    
    var contactsManager: ContactsManager!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(IssueDetailViewController.shareButtonPressed(_ :)))
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(madeCall), name: .callMade, object: nil)
        
        trackEvent("Topic", properties: ["IssueID": String(issue.id), "IssueTitle": issue.name])

        loadContacts()
    }

    private func loadContacts() {
        print("Loading contacts for: \(issue.contactAreas)")
        contactsManager.fetchContacts(location: UserLocation.current) { result in
            switch result {
            case .success(let contacts):
                self.contacts = contacts.filter {
                     self.issue.contactAreas.contains($0.area)
                }
                self.tableView.reloadData()
            case .failed(let error):
                let alert = UIAlertController(title: "Loading Error", message: "There was an error loading your representatives. \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                    self.loadContacts()
                }))
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @objc func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == IssueSections.header.rawValue else {
            return nil
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40.0))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width - 32.0, height: 40))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.addSubview(label)
        view.addSubview(button)

        view.backgroundColor = .fvc_lightGrayBackground
        label.text = R.string.localizable.callYourReps()
        label.textAlignment = .center
        label.font = .fvc_header
        button.addTarget(self, action: #selector(footerAction(_:)), for: .touchUpInside)
        return view
    }

    @objc func footerAction(_ sender: UIButton) {
        self.tableView.scrollToRow(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
    }
    
    @objc func madeCall() {
        logs = ContactLogs.load()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let issue = issue else {
            return assertionFailure("there was no issue for our issue detail controller")
        }
        
        AnalyticsManager.shared.trackEvent(withName: "Screen: Issue Detail", andProperties: ["issue_id": String(issue.id)])
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        logs = ContactLogs.load()

        if self.splitViewController == nil {
            navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            tableView.contentInset = UIEdgeInsets(top: IssuesContainerViewController.headerHeight, left: 0, bottom: 0, right: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadSections(IndexSet(integer: IssueSections.contacts.rawValue), with: .none)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let contacts = contacts else { return false }
        if identifier == R.segue.issueDetailViewController.callScript.identifier, self.splitViewController != nil, let indexPath = tableView.indexPathForSelectedRow {
            let controller = R.storyboard.main.callScriptController()!
            controller.issuesManager = issuesManager
            controller.issue = issue
            controller.contact = contacts[indexPath.row]
            controller.contacts = contacts
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .formSheet
            self.present(nav, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController,
            let loc = nav.viewControllers.first as? EditLocationViewController {
            loc.delegate = self
        } else if let call = segue.destination as? CallScriptViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let contacts = contacts else { return }
            call.issuesManager = issuesManager
            call.issue = issue
            call.contact = contacts[indexPath.row]
            call.contacts = contacts
        }
    }
    
    @objc func shareButtonPressed(_ button: UIBarButtonItem) {
        shareIssue(from: button)
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
    
    var isSplitDistrict: Bool {
        // FIXME: determine split district another way
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return IssueSections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == IssueSections.header.rawValue {
            return IssueHeaderRows.count.rawValue
        } else {
            if let contacts = self.contacts {
                return max(1, contacts.count)
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let contacts = contacts else { return UITableViewCell() }

        switch indexPath.section {
        case IssueSections.header.rawValue:
            return headerCell(at: indexPath)
        default:
            if contacts.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.setLocationCell, for: indexPath)! as SetLocationCell
                if isSplitDistrict {
                    cell.messageLabel.text = R.string.localizable.splitDistrictMessage()
                } else {
                    cell.messageLabel.text = R.string.localizable.setYourLocation()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contactCell, for: indexPath)!
                cell.borderTop = indexPath.row == 0
                let contact = contacts[indexPath.row]
                cell.nameLabel.text = contact.name
                cell.subtitleLabel.text = contact.area
                if let photoURL = contact.photoURL {
                    cell.avatarImageView.kf.setImage(with: photoURL)
                } else {
                    cell.avatarImageView.image = UIImage(named: "icon-office")
                }
                if let hasContacted = logs?.hasContacted(contactId: contact.id, forIssue: issue.id) {
                    cell.hasContacted = hasContacted
                }
                return cell
            }
        }
    }
    
    private func headerCell(at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case IssueHeaderRows.title.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.titleCell, for: indexPath)!
            cell.issueLabel.text = issue.name
            return cell
            
        case IssueHeaderRows.description.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.descriptionCell, for: indexPath)!
            cell.issueTextView.isScrollEnabled = false
            cell.issueTextView.isEditable = false

            let markdown = Down.init(markdownString: issue.reason)
            if let converted = try? markdown.toAttributedString(.default, stylesheet: Issue.style) {
                cell.issueTextView.attributedText = converted
            } else {
                cell.issueTextView.text = issue.reason
            }

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

        loadContacts()
        dismiss(animated: true, completion: nil)

//        issuesManager.fetchContacts(location: location) { result in
//
//            if self.isSplitDistrict {
//                let alertController = UIAlertController(title: R.string.localizable.splitDistrictTitle(), message: R.string.localizable.splitDistrictMessage(), preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: R.string.localizable.okButtonTitle(), style: .default ,handler: nil))
//                vc.present(alertController, animated: true, completion: nil)
//            } else {
//                self.dismiss(animated: true, completion: nil)
//            }
//
//
//            if let issue = self.issuesManager.issue(withId: self.issue.id) {
//                self.issue = issue
//                self.tableView.reloadSections([IssueSections.contacts.rawValue], with: .automatic)
//                self.scrollToBottom()
//            } else {
//                // weird state to be in, but the issue we're looking at
//                // no longer exists, so we'll just quietly (read: not quietly)
//                // pop back to the issues list
//                _ = self.navigationController?.popViewController(animated: true)
//            }
//        }
    }
}
