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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        if let zip = UserDefaults.standard.string(forKey: UserDefaultsKeys.zipCode.rawValue) {
            locationButton.setTitle(zip, for: .normal)
        }

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

    //Mark: EditLocationViewControllerDelegate

    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController) {
        dismiss(animated: true, completion: nil)
    }

    func editLocationViewController(_ vc: EditLocationViewController, didSelectZipCode zip: String) {
        locationButton.setTitle(zip, for: .normal)
        UserDefaults.standard.setValue(zip, forKey: UserDefaultsKeys.zipCode.rawValue)
        NotificationCenter.default.post(name: .zipCodeChanged, object: nil)
        dismiss(animated: true, completion: nil)
    }

    func editLocationViewController(_ vc: EditLocationViewController, didSelectLocation location: CLLocationCoordinate2D) {

    }
}
