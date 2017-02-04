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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var locationButton: UIButton!
    
    var issuesViewController: IssuesViewController!
    var issuesManager: IssuesManager {
        return issuesViewController.issuesManager
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel(location: UserLocation.current)

        let issuesVC = storyboard!.instantiateViewController(withIdentifier: "IssuesViewController") as! IssuesViewController
        addChildViewController(issuesVC)
        
        view.insertSubview(issuesVC.view, belowSubview: headerView)
        issuesVC.view.translatesAutoresizingMaskIntoConstraints = false
        issuesVC.tableView.contentInset.top = headerView.frame.size.height - 20 // status bar adjustment
        issuesVC.tableView.scrollIndicatorInsets.top = headerView.frame.size.height - 10
        
        NSLayoutConstraint.activate([
            issuesVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            issuesVC.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            issuesVC.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            issuesVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        issuesVC.didMove(toParentViewController: self)
        issuesViewController = issuesVC
        
        // NotificationCenter.default.addObserver(self, selector: #selector(IssuesContainerViewController.locationDidChange(_:)), name: .locationChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func setLocationTapped(_ sender: Any) {
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        dismiss(animated: true) { [weak self] in
            self?.issuesManager.userLocation = location
            self?.issuesViewController.loadIssues()
            self?.setTitleLabel(location: location)
        }
    }
    
    // MARK: - Private functions

    private func setTitleLabel(location: UserLocation?) {
        locationButton.setTitle(UserLocation.current.locationDisplay ?? "Set Location", for: .normal)
    }
}
