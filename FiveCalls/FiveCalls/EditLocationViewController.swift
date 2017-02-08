//
//  EditLocationViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/31/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation

protocol EditLocationViewControllerDelegate : NSObjectProtocol {
    func editLocationViewController(_ vc: EditLocationViewController, didUpdateLocation location: UserLocation)
    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController)
}

class EditLocationViewController : UIViewController, CLLocationManagerDelegate {
    weak var delegate: EditLocationViewControllerDelegate?
    private var lookupLocation: CLLocation?
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    @IBOutlet weak var useMyLocationButton: UIButton!
    @IBOutlet weak var zipCodeTextField: UITextField!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        zipCodeTextField.becomeFirstResponder()
        
        if case .zipCode? = UserLocation.current.locationType {
            zipCodeTextField.text = UserLocation.current.locationValue
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        zipCodeTextField.resignFirstResponder()
    }
    
    @IBAction func useMyLocationTapped(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .denied {
            informUserOfPermissions()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        delegate?.editLocationViewControllerDidCancel(self)
    }
    
    @IBAction func submitZipCodeTapped(_ sender: Any) {
        if validateZipCode() {
            let userLocation = UserLocation.current
            userLocation.setFrom(zipCode: zipCodeTextField.text!)
            delegate?.editLocationViewController(self, didUpdateLocation: userLocation)
        }
    }
    
    private func validateZipCode() -> Bool {
        let zip = zipCodeTextField.text!
        let regex = try! NSRegularExpression(pattern: "^\\d{5}$", options: [])
        if let _ = regex.firstMatch(in: zip, options: [], range: NSMakeRange(0, zip.characters.count)) {
            return true
        }

        let alert = UIAlertController(title: "Invalid Zip Code", message: "Please enter a 5-digit zip code", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
        return false
    }

    //Mark: CLLocationManagerDelegate methods
    
    func informUserOfPermissions() {
        let alertController = UIAlertController(title: "Location permission denied.", message:
            "To use Location please change the permissions in the Settings.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .default ,handler: nil)
        alertController.addAction(dismiss)
        let openSettings = UIAlertAction(title: "Open Settings", style: .default, handler: { action in
            guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.fvc_open(url)
        })
        alertController.addAction(openSettings)
        present(alertController, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .denied {
            useMyLocationButton.isEnabled = false // prevent starting it twice...
            activityIndicator.startAnimating()
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard lookupLocation == nil else { //only want to call delegate one time
            return
        }

        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            lookupLocation = location
            let userLocation = UserLocation.current
            userLocation.setFrom(location: location) {
                self.delegate?.editLocationViewController(self, didUpdateLocation: userLocation)
            }
            
        }
    }

}
