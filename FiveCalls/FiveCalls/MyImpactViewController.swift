//
//  MyImpactViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Rswift

class MyImpactViewController : UITableViewController {
    
    private var viewModel: ImpactViewModel!
    private var userStats: UserStats?
    private var totalCalls: Int?
    
    @IBOutlet weak var navSignInButton: UIBarButtonItem!
    @IBOutlet weak var signInContainer: UIView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var loginButton: UIButton!
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
        Current.analytics.trackEvent("Screen: My Impact")
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.fvc_header,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        displayProfileInfo()
        displayStats()
        fetchServerStats()
        
        profilePic.layer.borderColor = UIColor.white.cgColor
        profilePic.layer.borderWidth = 2.0

        sizeHeaderToFit()
        
        let totalCallsOp = FetchStatsOperation()
        totalCallsOp.completionBlock = {
            self.totalCalls = totalCallsOp.numberOfCalls
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        OperationQueue.main.addOperation(totalCallsOp)

        NotificationCenter.default.addObserver(self, selector: #selector(userProfileChanged), name: .userProfileChanged, object: nil)
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
        viewModel = ImpactViewModel(logs: Current.contactLogs.load(), stats: userStats)

        streakLabel.text = viewModel.weeklyStreakMessage
        impactLabel.text = viewModel.impactMessage

        if viewModel.numberOfCalls == 0 {
            subheadLabel.isHidden = true
            subheadLabel.addConstraint(NSLayoutConstraint(item: subheadLabel as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0))
        }

        tableView.reloadData()
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if (SessionManager.shared.userIsLoggedIn()) {
            SessionManager.shared.stopSession()
        } else {
            SessionManager.shared.startSession()
        }
    }
    
    @objc func userProfileChanged(_ notification: NSNotification) {
        fetchServerStats()
        
        DispatchQueue.main.async {
            self.displayProfileInfo()
        }
    }
    
    private func displayProfileInfo() {
        let sessionManager = SessionManager.shared
        if let picUrl = sessionManager.userProfile?.picture {
            self.profilePic.setImageFromURL(picUrl)
        } else {
            self.profilePic.image = UIImage(named: "profile")
        }
        if sessionManager.userIsLoggedIn() {
            self.userName.text = sessionManager.userProfile?.nickname
            self.email.text = sessionManager.userProfile?.email ?? sessionManager.userProfile?.name
            self.navSignInButton.title = R.string.localizable.signOut()
            self.profileContainer.isHidden = false
            self.signInContainer.isHidden = true
        } else {
            self.navSignInButton.title = R.string.localizable.signIn()
            self.profileContainer.isHidden = true
            self.signInContainer.isHidden = false
        }
    }
    
    private func fetchServerStats() {
        if SessionManager.shared.userIsLoggedIn() {
            // Fetch the user's call stats
            let userStatsOp = FetchUserStatsOperation()
            userStatsOp.completionBlock = {
                if let error = userStatsOp.error {
                    Current.analytics.trackError(error: error)
                }
                self.userStats = userStatsOp.userStats
                DispatchQueue.main.async {
                    self.displayStats()
                }
            }
            OperationQueue.main.addOperation(userStatsOp)
        } else {
            userStats = nil
            DispatchQueue.main.async {
                self.displayStats()
            }
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
