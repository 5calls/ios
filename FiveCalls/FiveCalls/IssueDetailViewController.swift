//
//  IssueDetailViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/2/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class IssueDetailViewController : UIViewController {
    
    var issuesManager: IssuesManager!
    var issue: Issue!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
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
            return issue.contacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case Sections.header.rawValue:
            return headerCell(at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func headerCell(at indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case HeaderRows.title.rawValue:
            return tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        case HeaderRows.description.rawValue:
            return tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)
        default:
            return UITableViewCell()
        }
    }
}

extension IssueDetailViewController : UITableViewDelegate {
    
}
