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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footer: UIView!
    @IBOutlet weak var resultUnavailableButton: ContactButton!
    @IBOutlet weak var resultVoicemailButton: ContactButton!
    @IBOutlet weak var resultContactedButton: ContactButton!
    @IBOutlet weak var resultSkipButton: ContactButton!
    @IBOutlet weak var resultNextButton: ContactButton!
    @IBOutlet weak var footerLabel: UILabel!
    @IBOutlet weak var footerHeightContraint: NSLayoutConstraint!
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
        
        setupView()
    }
    
    func setupView() {
        guard let issue = issue, let issueIndex = issue.contacts.index(where:{$0.id == contact.id}) else { return }
        title = "Contact \(issueIndex+1) of \(issue.contacts.count)"

        let hasCompleted = logs.hasCompleted(issue: issue.id, allContacts: issue.contacts)
        let hasContacted = logs.hasContacted(contactId: contact.id, forIssue: issue.id)
        if hasCompleted {
            self.footerHeightContraint.constant = 30
            self.footerLabel.text = "You've contacted everyone, great work!"
        } else {
            self.footerHeightContraint.constant = hasContacted ? 75 : 118
            self.footerLabel.text = hasContacted ? "You've already contacted \(self.contact.name)." : "Enter your call result to get the next call."
        }
        self.resultNextButton.isHidden = hasCompleted || !hasContacted
        self.resultUnavailableButton.isHidden = hasCompleted || hasContacted
        self.resultVoicemailButton.isHidden = hasCompleted || hasContacted
        self.resultContactedButton.isHidden = hasCompleted || hasContacted
        self.resultSkipButton.isHidden = hasCompleted || hasContacted
        
        footer.setNeedsUpdateConstraints()
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
        case resultSkipButton:
            outcomeType = "skip"
            break
        case resultVoicemailButton:
            outcomeType = "vm"
            break
        case resultUnavailableButton:
            outcomeType = "unavailable"
            break
        case resultNextButton:
            print("find next contact")
            break
        default:
            print("unknown button pressed")
        }
        //validate that a call button was actually pressed at some point?
        let log = ContactLog(issueId: issue.id, contactId: contact.id, phone: contact.phone, outcome: outcomeType, date: Date())
        reportCallOutcome(log)
        
        for contact in issue.contacts {
            if !logs.hasContacted(contactId: contact.id, forIssue: issue.id) {
                nextContact(contact)
                return
            }
        }
        if logs.hasCompleted(issue: issue.id, allContacts: issue.contacts) {
            _ = navigationController?.popToRootViewController(animated: true)
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
