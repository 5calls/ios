//
//  IssueScriptCell.swift
//  FiveCalls
//
//  Created by Tom Burns on 2/28/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class IssueScriptCell: UITableViewCell {

    @IBOutlet weak var scriptTextView: UITextView!
    

}

class CopyWarningTextView: UITextView {
    @IBOutlet var viewController: UIViewController?
    
    override func copy(_ sender: Any?) {
        if !UserDefaults.standard.bool(forKey: UserDefaultsKey.hasWarnedAboutDangersOfCopying.rawValue) {
            let alert = UIAlertController(title: R.string.localizable.thinkBeforeCopyingAlertTitle(), message: R.string.localizable.thinkBeforeCopyingAlertBody(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title:  R.string.localizable.okButtonTitle(), style: .cancel, handler: { action in }))
            self.viewController?.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasWarnedAboutDangersOfCopying.rawValue)
        }
        super.copy(sender)
    }
}
