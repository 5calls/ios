//
//  CallScriptViewController.swift
//  FiveCalls
//
//  Created by Patrick McCarron on 2/3/17.
//

import UIKit
import CoreLocation
import DropDown
import Crashlytics

class CallScriptViewController : UIViewController, IssueShareable {
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    var contactIndex = 0
    var contact: Contact!
    var logs = ContactLogs.load()
    var lastPhoneDialed: String?
    
    var isLastContactForIssue: Bool {
        let contactIndex = issue.contacts.index(of: contact)
        return contactIndex == issue.contacts.count - 1
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultInstructionsLabel: UILabel!
    @IBOutlet weak var resultUnavailableButton: BlueButton!
    @IBOutlet weak var resultVoicemailButton: BlueButton!
    @IBOutlet weak var resultContactedButton: BlueButton!
    @IBOutlet weak var resultSkipButton: BlueButton!
    @IBOutlet weak var checkboxView: CheckboxView!
    
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            tableView.contentInset = UIEdgeInsets(top: IssuesContainerViewController.headerHeight, left: 0, bottom: 0, right: 0)
            self.navigationItem.leftBarButtonItem = self.iPadDoneButton
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let issue = issue, let contactIndex = issue.contacts.index(of: contact) else {
            return
        }
        
        Answers.logCustomEvent(withName:"Action: Issue Call Script", customAttributes: ["issue_id":issue.id])
        self.contactIndex = contactIndex
        title = "Contact \(contactIndex+1) of \(issue.contacts.count)"

        let method = logs.methodOfContact(to: contact.id, forIssue: issue.id)
        self.resultContactedButton.isSelected = method == .contacted
        self.resultUnavailableButton.isSelected = method == .unavailable
        self.resultVoicemailButton.isSelected = method == .voicemail
    }
    
    func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func dismissCallScript() {
        self.dismiss(animated: true, completion: nil)
    }
    
    var iPadDoneButton: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissCallScript))
    }
    
    func callButtonPressed(_ button: UIButton) {
        Answers.logCustomEvent(withName:"Action: Dialed Number", customAttributes: ["contact_id":contact.id])
        callNumber(contact.phone)
    }

    fileprivate func callNumber(_ number: String) {
        
        self.lastPhoneDialed = number
        
        let defaults = UserDefaults.standard
        let firstCallInstructionsKey =  UserDefaultsKeys.hasSeenFirstCallInstructions.rawValue
        
        let callErrorCompletion: (Bool) -> Void = { [weak self] successful in
            if !successful {
                DispatchQueue.main.async {
                    self?.showCallFailedAlert()
                }
            }
        }
        
        if defaults.bool(forKey: firstCallInstructionsKey) {
            guard let dialURL = URL(string: "telprompt:\(number)") else { return }
            UIApplication.shared.fvc_open(dialURL, completion: callErrorCompletion)
        } else {
            let alertController = UIAlertController(title: R.string.localizable.firstCallAlertTitle(),
                                                    message:  R.string.localizable.firstCallAlertMessage(),
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: R.string.localizable.firstCallAlertCancel(),
                                             style: .cancel) { _ in
                                                alertController.dismiss(animated: true, completion: nil)
            }
            
            let callAction = UIAlertAction(title: R.string.localizable.firstCallAlertCall(),
                                             style: .default) { _ in
                                                alertController.dismiss(animated: true, completion: nil)
                                                guard let dialURL = URL(string: "tel:\(number)") else { return }
                                                UIApplication.shared.fvc_open(dialURL, completion: callErrorCompletion)
                                                
                                                defaults.set(true, forKey: firstCallInstructionsKey)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(callAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func reportCallOutcome(_ log: ContactLog) {
        logs.add(log: log)
        let operation = ReportOutcomeOperation(log:log)
        #if !debug  // don't report stats in debug builds
        OperationQueue.main.addOperation(operation)
        #endif
    }
    
    func hideResultButtons(animated: Bool) {
        let duration = animated ? 0.5 : 0
        let hideDuration = duration * 0.6
        UIView.animate(withDuration: hideDuration) {
            for button in [self.resultContactedButton, self.resultVoicemailButton, self.resultUnavailableButton, self.resultSkipButton] {
                button?.alpha = 0
            }
            self.resultInstructionsLabel.alpha = 0
        }
        
        checkboxView.alpha = 0
        checkboxView.transform = checkboxView.transform.scaledBy(x: 0.2, y: 0.2)
        checkboxView.isHidden = false
        
        UIView.animate(withDuration: duration, delay: duration * 0.75, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            self.checkboxView.alpha = 1
            self.checkboxView.transform = .identity
        }, completion: nil)
    }
    
    func handleCallOutcome(outcome: ContactOutcome) {
        // save & send log entry
        let contactedPhone = lastPhoneDialed ?? contact.phone
        let log = ContactLog(issueId: issue.id, contactId: contact.id, phone: contactedPhone, outcome: outcome, date: Date())
        reportCallOutcome(log)
    }
    
    @IBAction func resultButtonPressed(_ button: UIButton) {
        Answers.logCustomEvent(withName:"Action: Button \(button.titleLabel)", customAttributes: ["contact_id":contact.id])
        
        switch button {
        case resultContactedButton: handleCallOutcome(outcome: .contacted)
        case resultVoicemailButton: handleCallOutcome(outcome: .voicemail)
        case resultUnavailableButton: handleCallOutcome(outcome: .unavailable)
        case resultSkipButton: break
        default:
            print("unknown button pressed")
        }
     
        if isLastContactForIssue {
            hideResultButtons(animated: true)
        } else {
            let nextContact = issue.contacts[contactIndex + 1]
            showNextContact(nextContact)
        }
    }
    
    func showNextContact(_ contact: Contact) {
        let newController = R.storyboard.main.callScriptController()!
        newController.issuesManager = issuesManager
        newController.issue = issue
        newController.contact = contact
        navigationController?.replaceTopViewController(with: newController, animated: true)
    }
    
    func shareButtonPressed(_ button: UIBarButtonItem) {
        shareIssue(from: button)
    }
        
    private func showCallFailedAlert() {
        let alertController = UIAlertController(title: R.string.localizable.placeCallFailedTitle(),
                                                message:  R.string.localizable.placeCallFailedMessage(),
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: R.string.localizable.okButtonTitle(),
                                     style: .default) { _ in
                                        alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.contactDetailCell, for: indexPath)!
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
                    guard let strongSelf = self else { return }
                    if strongSelf.contact.fieldOffices.indices.contains(index) {
                        let phone = strongSelf.contact.fieldOffices[index].phone
                        Answers.logCustomEvent(withName:"Action: Dialed Alternate Number", customAttributes: ["contact_id":strongSelf.contact.id])
                        self?.callNumber(phone)
                    }
                }
            }
            cell.moreNumbersButton.addTarget(self, action: #selector(CallScriptViewController.moreNumbersTapped), for: .touchUpInside)
            // This helps both resizing labels we have actually display correctly 
            cell.layoutIfNeeded()
            return cell
            
        case CallScriptRows.script.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.scriptCell, for: indexPath)!
            cell.issueLabel.text = issue.script
            return cell
            
        default:
            return UITableViewCell()
            
        }
    }
    
    func moreNumbersTapped() {
        Answers.logCustomEvent(withName:"Action: Opened More Numbers", customAttributes: ["contact_id":contact.id])
        dropdown?.show()
    }
}

extension IssueDetailViewController : UITableViewDelegate {

}
