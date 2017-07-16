//
//  IssuesContainerViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/1/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation

class IssuesContainerViewController : UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var iPadShareButton: UIButton!
    @IBOutlet weak var editRemindersButton: UIButton!
    
    var issuesViewController: IssuesViewController!
    var issuesManager: IssuesManager {
        return issuesViewController.issuesManager
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
