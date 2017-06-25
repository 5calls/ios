//
//  IssuesContainerViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/1/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation

class IssuesContainerViewController : UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var iPadShareButton: UIButton!
    @IBOutlet weak var editRemindersButton: UIButton!
    
    var issuesViewController: IssuesViewController!
    var issuesManager: IssuesManager {
        return issuesViewController.issuesManager
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel(location: UserLocation.current)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setReminderBellStatus()
    }
    
    @IBAction func addReminderTapped(_ sender: UIButton) {
        if let reminderViewController = R.storyboard.about.enableReminderVC(),
            let navController = R.storyboard.about.aboutNavController() {
            navController.setViewControllers([reminderViewController], animated: false)
            present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private functions

    private func setTitleLabel(location: UserLocation?) {
        locationButton.setTitle(UserLocation.current.locationDisplay ?? "Set Location", for: .normal)
    }
    
    private func setReminderBellStatus() {
        let remindersEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.reminderEnabled.rawValue)
        editRemindersButton.isSelected = remindersEnabled
    }
}

extension IssuesContainerViewController : IssuesViewControllerDelegate {
    func didStartLoadingIssues() {
        activityIndicator.startAnimating()
    }
    
    func didFinishLoadingIssues() {
        activityIndicator.stopAnimating()
    }
}
