//
//  CallScriptViewController.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/3/17.
//

import UIKit
import CoreLocation
import DropDown

class CallScriptViewController : UIViewController, IssueShareable {
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    var contact: Contact!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultUnavailableButton: ContactButton!
    @IBOutlet weak var resultVoicemailButton: ContactButton!
    @IBOutlet weak var resultContactedButton: ContactButton!
    @IBOutlet weak var resultSkipButton: ContactButton!
    var dropdown: DropDown?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(IssueDetailViewController.shareButtonPressed(_ :)))
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func callButtonPressed(_ button: UIButton) {
        callNumber(contact.phone)
    }

    func callNumber(_ number: String) {
        print("dialing \(number)")
        if let dialURL = URL(string: "telprompt:\(number)") {
            UIApplication.shared.open(dialURL) { success in
                //Log the result
            }
        }
    }
    
    func reportCallOutcome(_ outcomeType: String) {
        if outcomeType.characters.count > 0 {
            let operation = ReportOutcomeOperation(issue: issue, contact: contact, result: outcomeType)
            OperationQueue.main.addOperation(operation)
        }
    }
    
    @IBAction func resultButtonPressed(_ button: UIButton) {
        var outcomeType = ""
        switch button {
        case resultContactedButton:
            outcomeType = "contacted"
            break
        case resultSkipButton:
            outcomeType = "" // Do we have a report for "skip" ?
            break
        case resultVoicemailButton:
            outcomeType = "vm"
            break
        case resultUnavailableButton:
            outcomeType = "unavailable"
            break
        default:
            print("unknown button pressed")
        }
        reportCallOutcome(outcomeType)
        
        // Struct passing around problems. This needs to be refactored / cleaned up.
        contact.hasContacted = true
        let oldContact: Contact! = contact
        for i in 0..<issuesManager.issuesList!.issues.count {
            if issuesManager.issuesList!.issues[i].id == self.issue.id {
                for j in 0..<issuesManager.issuesList!.issues[i].contacts.count {
                    if issuesManager.issuesList!.issues[i].contacts[j].id == oldContact.id {
                        issuesManager.issuesList!.issues[i].contacts[j].hasContacted = true
                    }
                    if issuesManager.issuesList!.issues[i].contacts[j].hasContacted == false {
                        contact = issuesManager.issuesList!.issues[i].contacts[j]
                        tableView.reloadData()
                    }
                }
            }
        }
        if (contact.hasContacted) {
            for i in 0..<issuesManager.issuesList!.issues.count {
                if issuesManager.issuesList!.issues[i].id == self.issue.id {
                    issuesManager.issuesList!.issues[i].madeCalls = true
                }
            }
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func shareButtonPressed(_ button: UIBarButtonItem) {
        shareIssue()
    }
}

enum CallScriptRows : Int {
    case contact
    case script
    case count
}

extension CallScriptViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CallScriptRows.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        
        case CallScriptRows.contact.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactDetailCell
            cell.callButton.setTitle(contact.phone, for: .normal)
            cell.callButton.addTarget(self, action: #selector(callButtonPressed(_:)), for: .touchUpInside)
            cell.nameLabel.text = contact.name
            cell.callingReasonLabel.text = contact.reason
            if let photoURL = contact.photoURL {
                cell.avatarImageView.setRemoteImage(url: photoURL)
            } else {
                cell.avatarImageView.image = cell.avatarImageView.defaultImage
            }
            
            cell.moreNumbersButton.isHidden = contact.fieldOffices.isEmpty
            if contact.fieldOffices.count > 0 {
                dropdown = DropDown(anchorView: cell.moreNumbersButton)
                dropdown?.dataSource = contact.fieldOffices.map { "\($0.phone) (\($0.city))" }
                dropdown?.selectionAction = { [weak self] index, item in
                    guard let phone = self?.contact.fieldOffices[index].phone else { return }
                    self?.callNumber(phone)
                }
            }
            cell.moreNumbersButton.addTarget(self, action: #selector(CallScriptViewController.moreNumbersTapped), for: .touchUpInside)
            
            return cell
            
        case CallScriptRows.script.rawValue:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "scriptCell", for: indexPath) as! IssueDetailCell
            cell.issueLabel.text = issue.script
            return cell
            
        default:
            
            return UITableViewCell()
            
        }
    }
    
    func moreNumbersTapped() {
        dropdown?.show()
    }
}

extension IssueDetailViewController : UITableViewDelegate {

}
