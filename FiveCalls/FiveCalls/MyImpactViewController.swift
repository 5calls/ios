//
//  MyImpactViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Crashlytics
import Rswift

class MyImpactViewController : UITableViewController {
    
    var viewModel: ImpactViewModel!
    var totalCalls: Int?
    
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var impactLabel: UILabel!
    @IBOutlet weak var subheadLabel: UILabel!
    
    enum Sections: Int {
        case stats
        case contacts
        case count
        
        var cellIdentifier: Rswift.ReuseIdentifier<UIKit.UITableViewCell>? {
            switch self {
            case .stats: return R.reuseIdentifier.statCell
            case .contacts: return R.reuseIdentifier.contactStatCell
            default: return nil
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
        Answers.logCustomEvent(withName:"Screen: My Impact")
        
        viewModel = ImpactViewModel(logs: ContactLogs.load().all)
        let weeklyStreakCount = viewModel.weeklyStreakCount
        streakLabel.text = weeklyStreakMessage(for: weeklyStreakCount)
        let numberOfCalls = viewModel.numberOfCalls
        impactLabel.text = impactMessage(for: numberOfCalls)
        subheadLabel.isHidden = numberOfCalls == 0
        
        let op = FetchStatsOperation()
        op.completionBlock = {
            self.totalCalls = op.numberOfCalls
            DispatchQueue.main.async {
                self.tableView.reloadData()    
            }
            
        }
        OperationQueue.main.addOperation(op)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let headerView = tableView.tableHeaderView {
            let height = subheadLabel.isHidden ? impactLabel.frame.maxY : (subheadLabel.frame.maxY + 25.0)
            headerView.frame.size.height = height
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier!, for: indexPath)!
        
        switch section {
        case .stats:
            configureStatRow(cell: cell, stat: StatRow(rawValue: indexPath.row)!)
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let total = totalCalls, section == Sections.stats.rawValue else { return nil }
        let statsVm = StatsViewModel(numberOfCalls: total)
        return R.string.localizable.communityCalls(statsVm.formattedNumberOfCalls)
    }

    private func weeklyStreakMessage(for weeklyStreakCount: Int) -> String {
        switch weeklyStreakCount {
        case 0:
            return R.string.localizable.yourWeeklyStreakZero(weeklyStreakCount)
        case 1:
            return R.string.localizable.yourWeeklyStreakSingle()
        default:
            return R.string.localizable.yourWeeklyStreakMultiple(weeklyStreakCount)
        }
    }
  
    private func impactMessage(for numberOfCalls: Int) -> String {
        switch numberOfCalls {
        case 0:
            return R.string.localizable.yourImpactZero(numberOfCalls)
        case 1:
            return R.string.localizable.yourImpactSingle(numberOfCalls)
        default:
            return R.string.localizable.yourImpactMultiple(numberOfCalls)
        }
    }
  
    private func configureStatRow(cell: UITableViewCell, stat: StatRow) {
        switch stat {
        case .madeContact:
            cell.textLabel?.text = R.string.localizable.madeContact()
            cell.detailTextLabel?.text = timesString(count: viewModel.madeContactCount)
        case .unavailable:
            cell.textLabel?.text = R.string.localizable.unavailable()
            cell.detailTextLabel?.text = timesString(count: viewModel.unavailableCount)
        case .voicemail:
            cell.textLabel?.text = R.string.localizable.leftVoicemail()
            cell.detailTextLabel?.text = timesString(count: viewModel.voicemailCount)
        default: break
        }
    }
    
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func timesString(count: Int) -> String {
        guard count != 1 else { return R.string.localizable.calledSingle(count) }
        return R.string.localizable.calledMultiple(count)
    }
}
