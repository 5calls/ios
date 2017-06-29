//
//  IssuesViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Crashlytics
import DZNEmptyDataSet

protocol IssuesViewControllerDelegate : class {
    func didStartLoadingIssues()
    func didFinishLoadingIssues()
}

class IssuesViewController : UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationButton: UIButton?
    @IBOutlet weak var locationBar: UINavigationBar?
    private var refreshControl: UIRefreshControl!

    @IBInspectable var shouldFetchAllIssues: Bool = false
    
    weak var issuesDelegate: IssuesViewControllerDelegate?
    var lastLoadResult: IssuesLoadResult?
    var isLoading = false
    
    // keep track of when calls are made, so we know if we need to reload any cells
    var needToReloadVisibleRowsOnNextAppearance = false

    private var notificationToken: NSObjectProtocol?
    
    var issuesManager = IssuesManager()
    var logs: ContactLogs?
    var iPadShareButton: UIButton? { didSet { self.iPadShareButton?.addTarget(self, action: #selector(share), for: .touchUpInside) }}
    
    struct ViewModel {
        let issues: [Issue]
    }
    var viewModel = ViewModel(issues: [])

    deinit {
        if let notificationToken = notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
        NotificationCenter.default.removeObserver(self, name: .callMade, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        self.registerForPreviewing(with: self, sourceView: tableView)

        Answers.logCustomEvent(withName:"Screen: Issues List")
        
        loadIssues()
        
        tableView.estimatedRowHeight = 75
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.tableFooterView = UIView()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadIssues), for: .valueChanged)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        notificationToken = NotificationCenter.default.addObserver(forName: .callMade, object: nil, queue: nil) { [weak self] _ in
            self?.needToReloadVisibleRowsOnNextAppearance = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(madeCall), name: .callMade, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)

        setTitleLabel(location: UserLocation.current)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logs = ContactLogs.load()
        
        // don't need to listen anymore because any change comes from this VC (otherwise we'll end up fetching twice)
        NotificationCenter.default.removeObserver(self, name: .locationChanged, object: nil)

        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // only reload rows if we need to. this fixes a rare tableview inconsistency crash we've seen
        if needToReloadVisibleRowsOnNextAppearance {
            tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
            needToReloadVisibleRowsOnNextAppearance = false
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // we need to know if location changes by any other VC so we can update our UI
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidChange(_:)), name: .locationChanged, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let locationBar = locationBar else {
            return
        }

        tableView.contentInset.top = locationBar.frame.maxY
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    func locationDidChange(_ notification: Notification) {
        let location = notification.object as! UserLocation
        setTitleLabel(location: location)
    }

    func share(button: UIButton) {
        if let nav = self.splitViewController?.viewControllers.last as? UINavigationController, let shareable = nav.viewControllers.last as? IssueShareable {
            shareable.shareIssue(from: button)
        }
    }

    func loadIssues() {
        isLoading = true
        tableView.reloadEmptyDataSet()
        issuesDelegate?.didStartLoadingIssues()

        let query: IssuesManager.Query = shouldFetchAllIssues ? .inactive : .active

        issuesManager.fetchIssues(forQuery: query, location: UserLocation.current) { [weak self] in
            self?.issuesLoaded(result: $0)
        }
    }

    private func issuesLoaded(result: IssuesLoadResult) {
        isLoading = false
        lastLoadResult = result
        issuesDelegate?.didFinishLoadingIssues()
        if case .success = result {
            viewModel = ViewModel(issues: issuesManager.issues)
            tableView.reloadData()
        } else {
            tableView.reloadEmptyDataSet()
        }
        refreshControl?.endRefreshing()
    }
    
    func madeCall() {
        logs = ContactLogs.load()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }

    func willEnterForeground() {
        loadIssues()
    }

    fileprivate func setTitleLabel(location: UserLocation?) {
        let locationTitle = location?.locationDisplay ?? "Set Location"
        locationButton?.setTitle(locationTitle, for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController, let vc = nc.topViewController as? EditLocationViewController {
            vc.delegate = self
            return
        }

        guard let indexPath = tableView.indexPathForSelectedRow else { return }

        var issueDetailViewController: IssueDetailViewController?

        if let typedInfo = R.segue.issuesViewController.issueSegue(segue: segue) {
            issueDetailViewController = typedInfo.destination.viewControllers.first as? IssueDetailViewController
        } else if let typedInfo = R.segue.issuesViewController.moreIssueSegue(segue: segue) {
            issueDetailViewController = typedInfo.destination.viewControllers.first as? IssueDetailViewController
        }

        issueDetailViewController?.issuesManager = issuesManager
        issueDetailViewController?.issue = viewModel.issues[indexPath.row]

    }

}

extension IssuesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard shouldFetchAllIssues else {
            return viewModel.issues.count + 1
        }

        return viewModel.issues.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let notAButton = BorderedButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 26.0))
        notAButton.setTitle(R.string.localizable.whatsImportantTitle(), for: .normal)
        notAButton.setTitleColor(.fvc_darkBlueText, for: .normal)
        notAButton.backgroundColor = .fvc_superLightGray
        notAButton.titleLabel?.font = Appearance.instance.headerFont
        notAButton.borderWidth = 1
        notAButton.borderColor = .fvc_mediumGray
        notAButton.topBorder = true
        notAButton.bottomBorder = true
        return notAButton
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.issues.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.moreIssuesCell, for: indexPath)!
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.issueCell, for: indexPath)!
        let issue = viewModel.issues[indexPath.row]
        cell.titleLabel.text = issue.name
        if let hasContacted = logs?.hasCompleted(issue: issue.id, allContacts: issue.contacts) {
            cell.checkboxView.isChecked = hasContacted
        }
        return cell
    }

}

extension IssuesViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let detailViewController = R.storyboard.main.issueDetailViewController() else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        detailViewController.issuesManager = issuesManager
        detailViewController.issue = issuesManager.issues[indexPath.row]
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
    
}

extension IssuesViewController: UIBarPositioningDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }
}

extension IssuesViewController : DZNEmptyDataSetSource {
    
    private func appropriateErrorMessage(for result: IssuesLoadResult) -> String {
        switch result {
        case .offline: return R.string.localizable.issueLoadFailedConnection()
        case .serverError(_): return R.string.localizable.issueLoadFailedServer()
        default:
            return ""
        }
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        let message = appropriateErrorMessage(for: lastLoadResult ?? .offline)
        
        return NSAttributedString(string: message,
                                  attributes: [
                                    NSFontAttributeName: Appearance.instance.bodyFont
                ])
    }
    
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> UIImage? {
        return #imageLiteral(resourceName: "refresh")
    }
    
}


extension IssuesViewController : DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return !isLoading
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        loadIssues()
        tableView.reloadEmptyDataSet()
    }
}

extension IssuesViewController: EditLocationViewControllerDelegate {

    func editLocationViewControllerDidCancel(_ vc: EditLocationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func editLocationViewController(_ vc: EditLocationViewController, didUpdateLocation location: UserLocation) {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) {
                self?.loadIssues()
                self?.setTitleLabel(location: location)
            }
        }
    }

}
