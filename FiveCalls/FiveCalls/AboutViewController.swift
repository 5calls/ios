//
//  AboutViewController.swift
//  FiveCalls
//
//  Created by Alex on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import UIKit
import Social
import MessageUI

class AboutViewController : UITableViewController, MFMailComposeViewControllerDelegate {

//    Test App id:
//    static let appId = "364909474"
    static let appId = "1202558609"

    static let appUrl = URL(string: "https://itunes.apple.com/us/app/myapp/id\(appId)?ls=1&mt=8")
        
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var followOnTwitterCell: UITableViewCell!
    @IBOutlet weak var shareCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clickedCell = tableView.cellForRow(at: indexPath)
        
        if(clickedCell == feedbackCell) {
            sendFeedback()
        } else if (clickedCell == followOnTwitterCell) {
            followOnTwitter()
        } else if (clickedCell == shareCell) {
            shareApp()
        } else if (clickedCell == rateCell) {
            promptForRating()
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

        let actionSheet = UIAlertController(title: "", message: "Share", preferredStyle: .actionSheet)
        
        let tweetAction = getTweetAction()
        let moreAction = getMoreAction()
        let fbAction = getFacebookAction()
        
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(fbAction)
        actionSheet.addAction(moreAction)
        
        present(actionSheet, animated: true, completion: nil)
       
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
    
    func getFacebookAction() -> UIAlertAction {
        return UIAlertAction(title: "Share on Facebook", style: .default, handler: {
            (action) -> Void in
            
            // check if Facebook service is available
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let fbComposerVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                fbComposerVC?.add(AboutViewController.appUrl)
                self.present(fbComposerVC!, animated: true, completion: nil)
            }
            else {
                self.showAlert(message:"You are not logged in to your Facebook account")
            }
        })
    }
    
    func getMoreAction() -> UIAlertAction {
        return UIAlertAction(title: "More", style: .default, handler: {
            (action) -> Void in
            guard let url = URL(string: "https://itunes.apple.com/us/app/myapp/id\(AboutViewController.appId)?ls=1&mt=8") else { return }
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.excludedActivityTypes = [UIActivityType.postToFacebook, UIActivityType.postToTwitter]
            self.present(vc, animated: true, completion: nil)
        })
        
    }
    
    func getTweetAction() -> UIAlertAction {
        return UIAlertAction(title: "Share on Twitter", style: .default, handler: {
            (action) -> Void in
            
            // check if Twitter service is available
            
            if (SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)) {
                let twitterComposerVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterComposerVC?.add(AboutViewController.appUrl)
                self.present(twitterComposerVC!, animated: true, completion: nil)
            }
            else {
                self.showAlert(message:"You are not logged in to your Twitter account")
            }
        })
    }
    
    func showAlert(message: String, alertTitle: String?=nil, alertStyle: UIAlertActionStyle?=nil, alertActionHandler: ((UIAlertAction) -> Void)?=nil) {
        var alertTitle = alertTitle
        var alertStyle = alertStyle
        let alertController = UIAlertController(title: "Share", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        if alertTitle == nil {
            alertTitle = "Okay"
        }
        
        if alertStyle == nil {
            alertStyle = UIAlertActionStyle.default
        }
        
        alertController.addAction(UIAlertAction(title: alertTitle!, style: alertStyle!, handler: alertActionHandler))
        self.present(alertController, animated: true, completion: nil)
    }

}
