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
    func editLocationViewController(_ vc: EditLocationViewController, didSelectLocation location: CLLocationCoordinate2D)
    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController)
}

class EditLocationViewController : UIViewController {
    weak var delegate: EditLocationViewControllerDelegate?
    
    @IBOutlet weak var useMyLocationButton: UIButton!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBAction func useMyLocationTapped(_ sender: Any) {
        
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
}
