//
//  IssueDetailViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import CoreLocation

class IssueDetailViewController : UIViewController {
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    
    @IBOutlet weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController,
            let loc = nav.viewControllers.first as? EditLocationViewController {
            loc.delegate = self
        }
    }
}

enum Sections : Int {
    case header
    case contacts
    case count
}

enum HeaderRows : Int {
    case title
    case description
    case count
}

extension IssueDetailViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Sections.header.rawValue {
            return HeaderRows.count.rawValue
        } else {
            return max(1, issue.contacts.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case Sections.header.rawValue:
            return headerCell(at: indexPath)
        default:
            
            if issue.contacts.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "setLocationCell", for: indexPath)
                return cell
            } else {
                // contact cell
            }
            
            return UITableViewCell()
        }
    }
    
    private func headerCell(at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case HeaderRows.title.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! IssueDetailCell
            cell.issueLabel.text = issue.name
            return cell
            
        case HeaderRows.description.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! IssueDetailCell
            cell.issueLabel.text = issue.reason
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

extension IssueDetailViewController : UITableViewDelegate {
    
}

extension IssueDetailViewController : EditLocationViewControllerDelegate {
    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func editLocationViewController(_ vc: EditLocationViewController, didSelectZipCode zip: String) {
        dismiss(animated: true, completion: nil)
        issuesManager.zipCode = zip
        issuesManager.fetchIssues {
            self.tableView.reloadData()
        }
    }
    
    func editLocationViewController(_ vc: EditLocationViewController, didSelectLocation location: CLLocationCoordinate2D) {
        dismiss(animated: true, completion: nil)
        issuesManager.fetchIssues {
            self.tableView.reloadData()
        }
    }
}
