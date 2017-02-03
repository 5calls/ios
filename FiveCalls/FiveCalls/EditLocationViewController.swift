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
    func editLocationViewController(_ vc: EditLocationViewController, didSelectZipCode zip: String)
    func editLocationViewController(_ vc: EditLocationViewController, didSelectLocation location: CLLocation)
    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController)
}

class EditLocationViewController : UIViewController, CLLocationManagerDelegate {
    weak var delegate: EditLocationViewControllerDelegate?
    private var lookupLocation: CLLocation?
    @IBOutlet weak var addressLabel: UILabel!

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    @IBOutlet weak var useMyLocationButton: UIButton!
    @IBOutlet weak var zipCodeTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let zip = UserDefaults.standard.string(forKey: UserDefaultsKeys.zipCode.rawValue) {
            zipCodeTextField.text = zip
        }
    }
    
    @IBAction func useMyLocationTapped(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        delegate?.editLocationViewControllerDidCancel(self)
    }
    
    @IBAction func submitZipCodeTapped(_ sender: Any) {
        if validateZipCode() {
            delegate?.editLocationViewController(self, didSelectZipCode: zipCodeTextField.text!)
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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard lookupLocation == nil else { //only want to call delegate one time
            return
        }

        if let location = locations.first {
            lookupLocation = location
            delegate?.editLocationViewController(self, didSelectLocation: location)
            locationManager.stopUpdatingLocation()
        }
    }

}
