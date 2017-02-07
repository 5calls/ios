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
    var logs = ContactLogs.load()
    var lastPhoneDialed = ""
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

        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(IssueDetailViewController.shareButtonPressed(_ :)))
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let issue = issue, let issueIndex = issue.contacts.index(where:{$0.id == contact.id}) else { return }
        title = "Contact \(issueIndex+1) of \(issue.contacts.count)"
    }
    
    func callButtonPressed(_ button: UIButton) {
        callNumber(contact.phone)
    }

    func callNumber(_ number: String) {
        lastPhoneDialed = number
        if let dialURL = URL(string: "telprompt:\(number)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(dialURL)
            } else {
                UIApplication.shared.openURL(dialURL)
            }
        }
    }
    
    func reportCallOutcome(_ log: ContactLog) {
        if log.outcome.characters.count > 0 {
            logs.add(log: log)
            let operation = ReportOutcomeOperation(log:log)
            OperationQueue.main.addOperation(operation)
        }
    }
    
    @IBAction func resultButtonPressed(_ button: UIButton) {
        var outcomeType = ""
        switch button {
        case resultContactedButton:
            outcomeType = "contacted"
            break
        case resultVoicemailButton:
            outcomeType = "vm"
            break
        case resultUnavailableButton:
            outcomeType = "unavailable"
            break
        case resultSkipButton:
            print("find next contact")
            break
        default:
            print("unknown button pressed")
        }
        let contactedPhone = lastPhoneDialed.characters.count > 0 ? lastPhoneDialed : contact.phone
        let log = ContactLog(issueId: issue.id, contactId: contact.id, phone: contactedPhone, outcome: outcomeType, date: Date())
        reportCallOutcome(log)
        for contact in issue.contacts {
            if !logs.hasContacted(contactId: contact.id, forIssue: issue.id) {
                nextContact(contact)
                return
            }
        }
        if logs.hasCompleted(issue: issue.id, allContacts: issue.contacts) {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func nextContact(_ contact: Contact) {
        let newController: CallScriptViewController = self.storyboard?.instantiateViewController(withIdentifier: "callScriptController") as! CallScriptViewController
        newController.issuesManager = issuesManager
        newController.issue = issue
        newController.contact = contact
        navigationController?.replaceTopViewController(with: newController, animated: true)
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
                dropdown?.dismissMode = .automatic
                dropdown?.selectionAction = { [weak self] index, item in
                    guard let phone = self?.contact.fieldOffices[index].phone else { return }
                    self?.callNumber(phone)
                }
            }
            cell.moreNumbersButton.addTarget(self, action: #selector(CallScriptViewController.moreNumbersTapped), for: .touchUpInside)
            //This helps both reizing labels we have actually display correctly 
            cell.layoutIfNeeded()
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
