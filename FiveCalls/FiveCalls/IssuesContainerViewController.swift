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
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var iPadShareButton: UIButton!
    @IBOutlet weak var iPadBackButton: UIButton!

    var issuesViewController: IssuesViewController!
    var issuesManager: IssuesManager {
        return issuesViewController.issuesManager
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel(location: UserLocation.current)

        let runningOnIPad = UIDevice.current.userInterfaceIdiom == .pad
        let issuesVC = R.storyboard.main.issuesViewController()!
        let childController: UIViewController

        if runningOnIPad {
            let splitController = UISplitViewController()
            splitController.preferredDisplayMode = .allVisible
            childController = splitController
            issuesVC.iPadShareButton = self.iPadShareButton
            issuesVC.iPadBackButton = self.iPadBackButton
            splitController.viewControllers = [issuesVC, UIViewController()]
        } else {
            childController = issuesVC
        }

        addChildViewController(childController)
        
        view.insertSubview(childController.view, belowSubview: headerView)
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            childController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            childController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            childController.view.bottomAnchor.constraint(equalTo: footerView.topAnchor)
            ])
        
        childController.didMove(toParentViewController: self)
        issuesViewController = issuesVC
    }
    
    private func setContentInset() {
        issuesViewController.tableView.contentInset.top = headerView.frame.size.height
        issuesViewController.tableView.scrollIndicatorInsets.top = headerView.frame.size.height
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setContentInset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        setContentInset()
        
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
