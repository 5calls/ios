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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
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
            
        default: break;
        }
    }
    
    func sendFeedback() {
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
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(AboutViewController.appId)") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // openURL(_:) is deprecated in iOS 10+.
            UIApplication.shared.openURL(url)
        }
    }
    
    func shareApp() {

        guard let url = URL(string: "https://itunes.apple.com/us/app/myapp/id\(AboutViewController.appId)?ls=1&mt=8") else { return }
        let vc = UIActivityViewController(activityItems: ["Make 5 Calls to your elected officials and let your voice be heard!",url], applicationActivities: [])
        vc.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .openInIBooks, .print, .saveToCameraRoll]
        self.present(vc, animated: true, completion: nil)
       
    }
    
    func followOnTwitter() {
        guard let url = URL(string: "https://twitter.com/make5calls") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // openURL(_:) is deprecated in iOS 10+.
            UIApplication.shared.openURL(url)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func showOpenSource() {
        let acknowledgementsVC = CPDAcknowledgementsViewController(style: nil, acknowledgements: nil, contributions: nil)
        navigationController?.pushViewController(acknowledgementsVC, animated: true)
    }

}
