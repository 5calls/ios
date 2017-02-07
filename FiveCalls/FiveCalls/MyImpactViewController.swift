//
//  MyImpactViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class MyImpactViewController : UITableViewController {
    
    var viewModel: ImpactViewModel!
    var totalCalls: Int?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheadLabel: UILabel!
    
    enum Sections: Int {
        case stats
        case contacts
        case count
        
        var cellIdentifier: String {
            switch self {
            case .stats: return "statCell"
            case .contacts: return "contactStatCell"
            default: return ""
            }
        }
    }
    
    enum StatRow: Int {
        case madeContact
        case voicemail
        case unavailable
        case count
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ImpactViewModel(logs: ContactLogs.load().all)
        
        let number = viewModel.numberOfCalls
        let calls = number == 1 ? "call" : "calls"
        let punctuation = number > 0  ? "!" : "."
        let template = headerLabel.text
        let headerString = template?.replacingOccurrences(of: "{{number}}", with: String(number))
                                    .replacingOccurrences(of: "{{calls}}", with: calls)
                                    .replacingOccurrences(of: "{{punctuation}}", with: punctuation)
        headerLabel.text = headerString
        
        subheadLabel.isHidden = number == 0
        
        
        let op = FetchStatsOperation()
        op.completionBlock = {
            self.totalCalls = op.numberOfCalls
            DispatchQueue.main.async {
                self.tableView.reloadData()    
            }
            
        }
        OperationQueue.main.addOperation(op)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section)! {
        case .stats:
            return StatRow.count.rawValue
            
        case .contacts:
            return 0
            
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Sections(rawValue: indexPath.section)!
        let identifier = section.cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch section {
        case .stats:
            configureStatRow(cell: cell, stat: StatRow(rawValue: indexPath.row)!)
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let total = totalCalls, section == Sections.stats.rawValue {
            let statsVm = StatsViewModel(numberOfCalls: total)
            return "The 5 Calls community has contributed \(statsVm.formattedNumberOfCalls!) calls!"
        }
        
        return nil
    }
    
    private func configureStatRow(cell: UITableViewCell, stat: StatRow) {
        switch stat {
        case .madeContact:
            cell.textLabel?.text = "Made Contact"
            cell.detailTextLabel?.text = timesString(count: viewModel.madeContactCount)
        case .unavailable:
            cell.textLabel?.text = "Unavailable"
            cell.detailTextLabel?.text = timesString(count: viewModel.unavailableCount)
        case .voicemail:
            cell.textLabel?.text = "Left Voicemail"
            cell.detailTextLabel?.text = timesString(count: viewModel.voicemailCount)
        default: break
        }
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func timesString(count: Int) -> String {
        return "\(count) time\( count == 1 ? "" : "s")"
    }
}
