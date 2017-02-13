//
//  AboutViewController.swift
//  FiveCalls
//
//  Created by Alex on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import CPDAcknowledgements
import Crashlytics

class AboutViewController : UITableViewController, MFMailComposeViewControllerDelegate {

//    Test App id:
//    static let appId = "364909474"
    static let appId = "1202558609"

    static let appUrl = URL(string: "https://itunes.apple.com/us/app/myapp/id\(appId)?ls=1&mt=8")
        
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var followOnTwitterCell: UITableViewCell!
    @IBOutlet weak var shareCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    @IBOutlet weak var openSourceCell: UITableViewCell!
    @IBOutlet weak var showWelcomeCell: UITableViewCell!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        Answers.logCustomEvent(withName:"Screen: About")
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let clickedCell = tableView.cellForRow(at: indexPath) else { return }
        
        switch clickedCell {
            
        case feedbackCell:          sendFeedback()
        case followOnTwitterCell:   followOnTwitter()
        case shareCell:             shareApp()
        case rateCell:              promptForRating()
        case openSourceCell:        showOpenSource()
        case showWelcomeCell:       showWelcome()
            
        default: break;
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func sendFeedback() {
        Answers.logCustomEvent(withName: "Action: Feedback")
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["make5calls@gmail.com"])
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true)
        } else {
            let alertController = UIAlertController(title: "Can't send mail", message:
                "Please configure an e-mail address in the Settings app", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default ,handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    
    }
    
    func promptForRating() {
        Answers.logCustomEvent(withName: "Action: Rate the App")
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(AboutViewController.appId)") else { return }
        UIApplication.shared.fvc_open(url)
    }
    
    func shareApp() {
        Answers.logCustomEvent(withName: "Action: Share The App")
        guard let url = URL(string: "https://itunes.apple.com/us/app/myapp/id\(AboutViewController.appId)?ls=1&mt=8") else { return }
        let vc = UIActivityViewController(activityItems: ["Make 5 Calls to your elected officials and let your voice be heard!",url], applicationActivities: [])
        vc.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .openInIBooks, .print, .saveToCameraRoll]
        self.present(vc, animated: true, completion: nil)
    }
    
    func followOnTwitter() {
        Answers.logCustomEvent(withName: "Action: Follow On Twitter")
        guard let url = URL(string: "https://twitter.com/make5calls") else { return }
        UIApplication.shared.fvc_open(url)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func showOpenSource() {
        Answers.logCustomEvent(withName: "Screen: Open Source Libraries")
        let acknowledgementsVC = CPDAcknowledgementsViewController(style: nil, acknowledgements: nil, contributions: nil)
        navigationController?.pushViewController(acknowledgementsVC, animated: true)
    }

    func showWelcome() {
        let welcomeStoryboard = R.storyboard.welcome()
        let welcomeVC = welcomeStoryboard.instantiateInitialViewController()! as! WelcomeViewController
        welcomeVC.completionBlock = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        present(welcomeVC, animated: true)
    }
}
