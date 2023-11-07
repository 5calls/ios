//
//  MyImpactViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import RswiftResources

class MyImpactViewController : UITableViewController {
    
    private var viewModel: ImpactViewModel!
    private var userStats: UserStats?
    private var totalCalls: Int?
    
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var impactLabel: UILabel!
    @IBOutlet weak var subheadLabel: UILabel!
    
    enum Sections: Int {
        case stats
        case contacts
        case count

        var cellIdentifier: RswiftResources.ReuseIdentifier<UIKit.UITableViewCell>? {
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
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.fvc_header,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        displayStats()
        fetchServerStats()

        sizeHeaderToFit()
        
        let totalCallsOp = FetchStatsOperation()
        totalCallsOp.completionBlock = {
            self.totalCalls = totalCallsOp.numberOfCalls
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        OperationQueue.main.addOperation(totalCallsOp)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func sizeHeaderToFit() {
        let headerView = tableView.tableHeaderView!
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    func displayStats() {
        viewModel = ImpactViewModel(logs: ContactLogs.load(), stats: userStats)

        streakLabel.text = viewModel.weeklyStreakMessage
        impactLabel.text = viewModel.impactMessage

        if viewModel.numberOfCalls == 0 {
            subheadLabel.isHidden = true
            subheadLabel.addConstraint(NSLayoutConstraint(item: subheadLabel as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
        }

        tableView.reloadData()
    }
    
    private func fetchServerStats() {
        // Fetch the user's call stats
        let userStatsOp = FetchUserStatsOperation()
        userStatsOp.completionBlock = {
            if let error = userStatsOp.error {
                AnalyticsManager.shared.trackError(error: error)
            }
            self.userStats = userStatsOp.userStats
            DispatchQueue.main.async {
                self.displayStats()
            }
        }
        OperationQueue.main.addOperation(userStatsOp)
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
