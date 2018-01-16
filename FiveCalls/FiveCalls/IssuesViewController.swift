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

class IssuesViewController : UITableViewController {

    // When false, we show only 'active' issues.
    // Otherwise we show all issues - plus issues are grouped by their categories.
    @IBInspectable var shouldShowAllIssues: Bool = false
    
    weak var issuesDelegate: IssuesViewControllerDelegate?
    var lastLoadResult: IssuesLoadResult?
    var isLoading = false
    
    // keep track of when calls are made, so we know if we need to reload any cells
    var needToReloadVisibleRowsOnNextAppearance = false

    private var notificationToken: NSObjectProtocol?

    // Should be passed by the caller.
    var issuesManager: IssuesManager!

    var logs: ContactLogs?
    var iPadShareButton: UIButton? { didSet { self.iPadShareButton?.addTarget(self, action: #selector(share), for: .touchUpInside) }}
    
    var viewModel : IssuesViewModel!

    deinit {
        if let notificationToken = notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
        NotificationCenter.default.removeObserver(self, name: .callMade, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Construct viewModel from the issues already fetched by the caller.
        viewModel = createViewModelForCategories(categories: self.issuesManager.categories)

        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        self.registerForPreviewing(with: self, sourceView: tableView)

        Answers.logCustomEvent(withName:"Screen: Issues List")
        
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Refetch data only if we don't have anything to display.
        if viewModel.hasNoData() {
            loadIssues()
        }

        tableView.tableFooterView = UIView()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadIssues), for: .valueChanged)
        
        notificationToken = NotificationCenter.default.addObserver(forName: .callMade, object: nil, queue: nil) { [weak self] _ in
            self?.needToReloadVisibleRowsOnNextAppearance = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(madeCall), name: .callMade, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logs = ContactLogs.load()
        if shouldShowAllIssues {
            navigationController?.setNavigationBarHidden(false, animated: animated)
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

    @objc func share(button: UIButton) {
        if let nav = self.splitViewController?.viewControllers.last as? UINavigationController, let shareable = nav.viewControllers.last as? IssueShareable {
            shareable.shareIssue(from: button)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc func loadIssues() {
        isLoading = true
        tableView.reloadEmptyDataSet()
        issuesDelegate?.didStartLoadingIssues()

        issuesManager.fetchIssues(location: UserLocation.current) { [weak self] in
            self?.issuesLoaded(result: $0)
        }
    }

    private func createViewModelForCategories(categories: [Category]) -> IssuesViewModel {
        if shouldShowAllIssues {
            return AllIssuesViewModel(categories: categories)
        }
        return ActiveIssuesViewModel(categories: categories)
    }

    private func issuesLoaded(result: IssuesLoadResult) {
        isLoading = false
        lastLoadResult = result
        issuesDelegate?.didFinishLoadingIssues()
        if case .success = result {
            DispatchQueue.global(qos: .background).async { [unowned self] () -> Void in
                let viewModel = self.createViewModelForCategories(categories: self.issuesManager.categories)
                DispatchQueue.main.async {
                    self.viewModel = viewModel
                    self.tableView.reloadData()
                }
            }
        } else {
            tableView.reloadEmptyDataSet()
        }
        refreshControl?.endRefreshing()
    }

    private func headerWithTitle(title: String) -> UIView {
        let notAButton = BorderedButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 26.0))
        notAButton.setTitle(title, for: .normal)
        notAButton.setTitleColor(.fvc_darkBlueText, for: .normal)
        notAButton.backgroundColor = .fvc_superLightGray
        notAButton.titleLabel?.font = Appearance.instance.headerFont
        notAButton.borderWidth = 1
        notAButton.borderColor = .fvc_mediumGray
        notAButton.topBorder = true
        notAButton.bottomBorder = true
        return notAButton
    }
    
    @objc func madeCall() {
        logs = ContactLogs.load()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }

    @objc func willEnterForeground() {
        loadIssues()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == R.segue.issuesViewController.issueSegue.identifier, let split = self.splitViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return true }
            let controller = R.storyboard.main.issueDetailViewController()!
            controller.issuesManager = issuesManager
            controller.issue = viewModel.issueForIndexPath(indexPath: indexPath)

            let nav = UINavigationController(rootViewController: controller)
            nav.setNavigationBarHidden(true, animated: false)
            split.showDetailViewController(nav, sender: self)
            self.iPadShareButton?.isHidden = false
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typedInfo = R.segue.issuesViewController.moreSegue(segue: segue) {
            typedInfo.destination.issuesManager = issuesManager
        }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if let typedInfo = R.segue.issuesViewController.issueSegue(segue: segue) {
            typedInfo.destination.issuesManager = issuesManager
            typedInfo.destination.issue = viewModel.issueForIndexPath(indexPath: indexPath)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Display 'more issues' row in the last section, if we are showing 'active' issues only.
        let isLastSection = (viewModel.numberOfSections() - 1 == section)
        let moreIssuesRow = (isLastSection && !shouldShowAllIssues) ? 1 : 0

        return viewModel.numberOfRowsInSection(section: section) + moreIssuesRow
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = viewModel.titleForHeaderInSection(section: section)
        return headerWithTitle(title: title)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.numberOfRowsInSection(section: indexPath.section) else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.moreIssuesCell, for: indexPath)!
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.issueCell, for: indexPath)!
        let issue = viewModel.issueForIndexPath(indexPath: indexPath)
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
        detailViewController.issue = viewModel.issueForIndexPath(indexPath: indexPath)
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
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
                                    NSAttributedStringKey.font: Appearance.instance.bodyFont
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
