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
        //TODO: set zip based on whatever user last set.
        //TODO: need a function/extension that handles deciding between zipcode or location
        if let zip = UserDefaults.standard.string(forKey: UserDefaultsKeys.zipCode.rawValue) {
            locationButton.setTitle(zip, for: .normal)
        } else if let locationInfo = UserDefaults.standard.value(forKey: UserDefaultsKeys.locationInfo.rawValue) as? [String: Any] {
            let displayName = (locationInfo["displayName"] as? String) ?? "Selected Location"
            self.locationButton.setTitle(displayName, for: .normal)
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

    //Mark: EditLocationViewControllerDelegate

    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController) {
        dismiss(animated: true, completion: nil)
    }

    func editLocationViewController(_ vc: EditLocationViewController, didSelectZipCode zip: String) {
        locationButton.setTitle(zip, for: .normal)
        updateWith(zipCode: zip)
        dismiss(animated: true, completion: nil)
    }

    func editLocationViewController(_ vc: EditLocationViewController, didSelectLocation location: CLLocation) {
        getLocationInfo(from: location) { locationInfo in
            self.dismiss(animated: true, completion: nil)
            self.updateWith(locationInfo: locationInfo)
            self.locationButton.setTitle((locationInfo["displayName"] as? String) ?? "Selected Location", for: .normal)
        }
    }

    //Mark: private functions
    private func getLocationInfo(from location: CLLocation, completion: @escaping (([String: Any]) -> ())) {
        let geocoder = CLGeocoder()
        var locationInfo = [String: Any]()
        locationInfo["longitude"] = location.coordinate.longitude
        locationInfo["latitude"] = location.coordinate.latitude
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            let prefix = placemarks?.first?.subThoroughfare ?? ""
            let street = placemarks?.first?.thoroughfare ?? ""
            let streetAddress = prefix + " " + street
            locationInfo["displayName"] = streetAddress != " " ? streetAddress : nil
            locationInfo["zipcode"] = placemarks?.first?.postalCode ?? ""
            completion(locationInfo)
        })
    }

    private func updateWith(zipCode: String) {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.locationInfo.rawValue)
        UserDefaults.standard.setValue(zipCode, forKey: UserDefaultsKeys.zipCode.rawValue)
        NotificationCenter.default.post(name: .zipCodeChanged, object: nil)
    }

    private func updateWith(locationInfo: [String: Any]) {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.zipCode.rawValue)
        UserDefaults.standard.setValue(locationInfo, forKey: UserDefaultsKeys.locationInfo.rawValue)
        NotificationCenter.default.post(name: .locationChanged, object: nil)
    }
}
