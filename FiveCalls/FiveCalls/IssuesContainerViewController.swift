//
//  IssuesContainerViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/1/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation

class IssuesContainerViewController : UIViewController, EditLocationViewControllerDelegate {
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

        // don't need to listen anymore because any change comes from this VC (otherwise we'll end up fetching twice)
        NotificationCenter.default.removeObserver(self, name: .locationChanged, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // we need to know if location changes by any other VC so we can update our UI
        NotificationCenter.default.addObserver(self, selector: #selector(IssuesContainerViewController.locationDidChange(_:)), name: .locationChanged, object: nil)
    }
    
    @IBAction func setLocationTapped(_ sender: Any) {
    }
    
    @IBAction func addReminderTapped(_ sender: UIButton) {
        if let reminderViewController = R.storyboard.about.enableReminderVC(),
            let navController = R.storyboard.about.aboutNavController() {
            navController.setViewControllers([reminderViewController], animated: false)
            present(navController, animated: true, completion: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController,
            let vc = nc.topViewController as? EditLocationViewController {
            vc.delegate = self
        }
    }
    
    func locationDidChange(_ notification: Notification) {
        let location = notification.object as! UserLocation
        setTitleLabel(location: location)
    }

    // MARK: - EditLocationViewControllerDelegate

    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func editLocationViewController(_ vc: EditLocationViewController, didUpdateLocation location: UserLocation) {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) {
                self?.issuesViewController.loadIssues()
                self?.setTitleLabel(location: location)
            }
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
