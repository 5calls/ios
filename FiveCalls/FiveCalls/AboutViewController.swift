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
import StoreKit

class AboutViewController : UITableViewController, MFMailComposeViewControllerDelegate {

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
        Current.analytics.trackEvent("Screen: About")
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let clickedCell = tableView.cellForRow(at: indexPath) else { return }
        
        switch clickedCell {
            
        case feedbackCell:          sendFeedback()
        case followOnTwitterCell:   followOnTwitter()
        case shareCell:             shareApp(from: tableView.cellForRow(at: indexPath))
        case rateCell:              promptForRating()
        case openSourceCell:        showOpenSource()
        case showWelcomeCell:       showWelcome()
            
        default: break;
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let label = UILabel(frame: .zero)
            label.text = "v" + version
            label.textColor = .lightGray
            label.textAlignment = .center
            label.font = .preferredFont(forTextStyle: .caption1)
            return label
        }
        return nil
    }
    
    func sendFeedback() {
        Current.analytics.trackEvent("Action: Feedback")
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["make5calls@gmail.com"])
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true)
        } else {
            let alertController = UIAlertController(title: R.string.localizable.cantSendEmailTitle(), message: R.string.localizable.cantSendEmailMessage(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: R.string.localizable.dismissTitle(), style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    
    }
    
    func promptForRating() {
        Current.analytics.trackEvent("Action: Rate the App")
        SKStoreReviewController.requestReview()
    }
    
    func shareApp(from view: UIView?) {
        Current.analytics.trackEvent("Action: Share The App")
        guard let url = AboutViewController.appUrl else { return }
        let vc = UIActivityViewController(activityItems: [R.string.localizable.shareTheAppMessage(), url], applicationActivities: [])
        vc.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .openInIBooks, .print, .saveToCameraRoll]
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.popoverPresentationController?.sourceRect = view?.bounds ?? self.view.bounds
            vc.popoverPresentationController?.sourceView = view ?? self.view
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func followOnTwitter() {
        Current.analytics.trackEvent("Action: Follow On Twitter")
        guard let url = URL(string: "https://twitter.com/make5calls") else { return }
        UIApplication.shared.open(url)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func showOpenSource() {
        Current.analytics.trackEvent("Screen: Open Source Libraries")
        let acknowledgementsVC = CPDAcknowledgementsViewController(style: nil, acknowledgements: nil, contributions: nil)
        navigationController?.pushViewController(acknowledgementsVC, animated: true)
    }

    func showWelcome() {
        let welcomeVC = R.storyboard.welcome.welcomeViewController()!
        welcomeVC.completionBlock = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        present(welcomeVC, animated: true)
    }
}
