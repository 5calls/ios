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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var iPadShareButton: UIButton!
    @IBOutlet weak var editRemindersButton: UIButton!
    @IBOutlet weak var fiveCallsButton: UIButton!
    
    static let headerHeight: CGFloat = 90
    var issuesViewController: IssuesViewController!
    var issuesManager: IssuesManager {
        return issuesViewController.issuesManager
    }
    
    lazy var effectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(frame: self.headerContainer.bounds)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.effect = UIBlurEffect(style: .light)
        
        return effectView
    }()
    
    private func configureChildViewController() {
        let isRegularWidth = traitCollection.horizontalSizeClass == .regular
        let issuesVC = R.storyboard.main.issuesViewController()!
        issuesVC.issuesManager = IssuesManager()
        issuesVC.issuesDelegate = self
        let childController: UIViewController
        
        if isRegularWidth {
            let splitController = UISplitViewController()
            splitController.viewControllers = [issuesVC, UIViewController()]
            splitController.preferredDisplayMode = .allVisible
            childController = splitController
            issuesVC.iPadShareButton = self.iPadShareButton
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            childController = issuesVC
        }
        
        addChildViewController(childController)
        
        view.insertSubview(childController.view, belowSubview: headerContainer)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleLabel(location: UserLocation.current)
        configureChildViewController()
        setupHeaderWithBlurEffect()
        editRemindersButton.tintColor = .fvc_darkBlue
        locationButton.tintColor = .fvc_darkBlue
        let image = UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate)
        editRemindersButton.setImage(image, for: .normal)
        if SessionManager.shared.userHasCredentials() {
            SessionManager.shared.startSession()
        }
    }
    
    private func setupHeaderWithBlurEffect() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(headerView)
        headerContainer.addSubview(effectView)
        
        NSLayoutConstraint.activate([
            effectView.contentView.topAnchor.constraint(equalTo: headerView.topAnchor),
            effectView.contentView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            effectView.contentView.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            effectView.contentView.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            
            headerContainer.topAnchor.constraint(equalTo: effectView.topAnchor),
            headerContainer.bottomAnchor.constraint(equalTo: effectView.bottomAnchor),
            headerContainer.leftAnchor.constraint(equalTo: effectView.leftAnchor),
            headerContainer.rightAnchor.constraint(equalTo: effectView.rightAnchor)
            ])
    }
    
    private func setContentInset() {
        // Fix for odd force unwrapping in crash noted in bug #75
        guard issuesViewController != nil && headerContainer != nil else { return }
        issuesViewController.tableView.contentInset.top = headerContainer.frame.size.height
        issuesViewController.tableView.scrollIndicatorInsets.top = headerContainer.frame.size.height
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection != nil && previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            issuesViewController.willMove(toParentViewController: nil)
            issuesViewController.view.constraints.forEach { constraint in
                issuesViewController.view.removeConstraint(constraint)
            }
            issuesViewController.view.removeFromSuperview()
            issuesViewController.removeFromParentViewController()
            
            configureChildViewController()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setContentInset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
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
    
    @objc func locationDidChange(_ notification: Notification) {
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
}

extension IssuesContainerViewController : IssuesViewControllerDelegate {
    func didStartLoadingIssues() {
        activityIndicator.startAnimating()
    }
    
    func didFinishLoadingIssues() {
        activityIndicator.stopAnimating()
    }
}
