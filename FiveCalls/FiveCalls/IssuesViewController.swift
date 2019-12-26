//
//  IssuesViewController.swift
//  FiveCalls
//
//  Created by Ben Scheirman on 1/30/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol IssuesViewControllerDelegate : class {
    func didStartLoadingIssues()
    func didFinishLoadingIssues()
}

class IssuesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    // When false, we show only 'active' issues.
    // Otherwise we show all issues - plus issues are grouped by their categories.
    @IBInspectable var shouldShowAllIssues: Bool = false

    weak var issuesDelegate: IssuesViewControllerDelegate?
    var lastLoadResult: LoadResult?
    var isLoading = false
    var analyticsEvent: String {
        if shouldShowAllIssues {
            return "More"
        } else {
            return "Home"
        }
    }

    // keep track of when calls are made, so we know if we need to reload any cells
    var needToReloadVisibleRowsOnNextAppearance = false

    private var notificationToken: NSObjectProtocol?

    // Should be passed by the caller.
    var issuesManager: IssuesManager!
    var contactsManager: ContactsManager!
    private var contacts: [Contact]?

    var logs: ContactLogs?
    var iPadShareButton: UIButton? { didSet { self.iPadShareButton?.addTarget(self, action: #selector(share), for: .touchUpInside) }}

    var viewModel : IssuesViewModel!

    deinit {
        if let notificationToken = notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
        NotificationCenter.default.removeObserver(self, name: .callMade, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Construct viewModel from the issues already fetched by the caller.
        viewModel = createViewModelForCategories(issues: self.issuesManager.issues)

        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        self.registerForPreviewing(with: self, sourceView: tableView)

        AnalyticsManager.shared.trackEvent(withName: "Screen: Issues List")
        trackEvent(analyticsEvent)

        navigationController?.setNavigationBarHidden(true, animated: false)

        // Refetch data only if we don't have anything to display.
        if viewModel.hasNoData() {
            loadIssues()
        }

        tableView.contentInsetAdjustmentBehavior = .automatic
//        tableView.insetsContentViewsToSafeArea = false
//        tableView.insetsLayoutMarginsFromSafeArea = false
//        self.tableView.safeAreaInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)

        tableView.tableFooterView = UIView()

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadIssues), for: .valueChanged)

        notificationToken = NotificationCenter.default.addObserver(forName: .callMade, object: nil, queue: nil) { [weak self] _ in
            self?.needToReloadVisibleRowsOnNextAppearance = true
        }

        NotificationCenter.default.addObserver(self, selector: #selector(madeCall), name: .callMade, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logs = ContactLogs.load()
        if shouldShowAllIssues {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        if !shouldShowAllIssues && UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            navigationItem.title = R.string.localizable.whatsImportantTitle()
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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

        issuesManager.fetchIssues { [weak self] in
            self?.issuesLoaded(result: $0)
        }

        contactsManager.fetchContacts(location: UserLocation.current) { result in
            if case .success(let contacts) = result {
                self.contacts = contacts
                self.tableView.reloadData()
            }
        }
    }

    private func createViewModelForCategories(issues: [Issue]) -> IssuesViewModel {
        if shouldShowAllIssues {
            return AllIssuesViewModel(issues: issues)
        }
        return ActiveIssuesViewModel(issues: issues)
    }

    private func issuesLoaded(result: LoadResult) {
        isLoading = false
        lastLoadResult = result
        issuesDelegate?.didFinishLoadingIssues()
        if case .success = result {
            DispatchQueue.global(qos: .background).async { [unowned self] () -> Void in
                let viewModel = self.createViewModelForCategories(issues: self.issuesManager.issues)
                DispatchQueue.main.async {
                    self.viewModel = viewModel
                    self.tableView.reloadData()
                }
            }
        } else {
            tableView.reloadEmptyDataSet()
        }
        tableView.refreshControl?.endRefreshing()
    }

    private func headerWithTitle(title: String) -> UIView {
        let notAButton = BorderedButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 16.0))
        notAButton.setTitle(title, for: .normal)
        notAButton.setTitleColor(.fvc_darkGray, for: .normal)
        notAButton.backgroundColor = .fvc_lightGray
        notAButton.titleLabel?.font = .fvc_header
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
            typedInfo.destination.contactsManager = contactsManager
        }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if let typedInfo = R.segue.issuesViewController.issueSegue(segue: segue) {
            typedInfo.destination.issuesManager = issuesManager
            typedInfo.destination.contactsManager = contactsManager
            typedInfo.destination.issue = viewModel.issueForIndexPath(indexPath: indexPath)
        }
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Display 'more issues' row in the last section, if we are showing 'active' issues only.
        let isLastSection = (viewModel.numberOfSections() - 1 == section)
        let moreIssuesRow = (isLastSection && !shouldShowAllIssues) ? 1 : 0

        return viewModel.numberOfRowsInSection(section: section) + moreIssuesRow
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = viewModel.titleForHeaderInSection(section: section)
        return headerWithTitle(title: title)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !shouldShowAllIssues && UIDevice.current.userInterfaceIdiom == .pad {
            return 0
        }
        return 35.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < viewModel.numberOfRowsInSection(section: indexPath.section) else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.moreIssuesCell, for: indexPath)!
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.issueCell, for: indexPath)!
        let issue = viewModel.issueForIndexPath(indexPath: indexPath)
        cell.titleLabel.text = issue.name

        let issueContacts = (contacts ?? []).filter {
            issue.contactAreas.contains($0.area)
        }

        var numContactsContacted = 0
        for contact in issueContacts {
            if let contacted = logs?.hasContacted(contact: contact, forIssue: issue) {
                if contacted {
                    numContactsContacted = numContactsContacted + 1
                }
            }
        }

//        // avoid NaN problem if there are no contacts
        let progress = issueContacts.count < 1 ? 0.0 : Double(numContactsContacted) / Double(issueContacts.count)
        cell.progressView.progress = progress

        return cell
    }
}

//class OldIssuesViewController : UITableViewController {
//
//    // When false, we show only 'active' issues.
//    // Otherwise we show all issues - plus issues are grouped by their categories.
//    @IBInspectable var shouldShowAllIssues: Bool = false
//
//    weak var issuesDelegate: IssuesViewControllerDelegate?
//    var lastLoadResult: LoadResult?
//    var isLoading = false
//    var analyticsEvent: String {
//        if shouldShowAllIssues {
//            return "More"
//        } else {
//            return "Home"
//        }
//    }
//
//    // keep track of when calls are made, so we know if we need to reload any cells
//    var needToReloadVisibleRowsOnNextAppearance = false
//
//    private var notificationToken: NSObjectProtocol?
//
//    // Should be passed by the caller.
//    var issuesManager: IssuesManager!
//    var contactsManager: ContactsManager!
//    private var contacts: [Contact]?
//
//    var logs: ContactLogs?
//    var iPadShareButton: UIButton? { didSet { self.iPadShareButton?.addTarget(self, action: #selector(share), for: .touchUpInside) }}
//
//    var viewModel : IssuesViewModel!
//
//    deinit {
//        if let notificationToken = notificationToken {
//            NotificationCenter.default.removeObserver(notificationToken)
//        }
//        NotificationCenter.default.removeObserver(self, name: .callMade, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Construct viewModel from the issues already fetched by the caller.
//        viewModel = createViewModelForCategories(issues: self.issuesManager.issues)
//
//        tableView.emptyDataSetDelegate = self
//        tableView.emptyDataSetSource = self
//        self.registerForPreviewing(with: self, sourceView: tableView)
//
//        AnalyticsManager.shared.trackEvent(withName: "Screen: Issues List")
//        trackEvent(analyticsEvent)
//
//        navigationController?.setNavigationBarHidden(true, animated: false)
//
//        // Refetch data only if we don't have anything to display.
//        if viewModel.hasNoData() {
//            loadIssues()
//        }
//
//        tableView.tableFooterView = UIView()
//
//        refreshControl = UIRefreshControl()
//        refreshControl?.addTarget(self, action: #selector(loadIssues), for: .valueChanged)
//
//        notificationToken = NotificationCenter.default.addObserver(forName: .callMade, object: nil, queue: nil) { [weak self] _ in
//            self?.needToReloadVisibleRowsOnNextAppearance = true
//        }
//
//        NotificationCenter.default.addObserver(self, selector: #selector(madeCall), name: .callMade, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        logs = ContactLogs.load()
//        if shouldShowAllIssues {
//            navigationController?.setNavigationBarHidden(false, animated: animated)
//        }
//        if !shouldShowAllIssues && UIDevice.current.userInterfaceIdiom == .pad {
//            navigationController?.setNavigationBarHidden(false, animated: animated)
//            navigationItem.title = R.string.localizable.whatsImportantTitle()
//            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        // only reload rows if we need to. this fixes a rare tableview inconsistency crash we've seen
//        if needToReloadVisibleRowsOnNextAppearance {
//            tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
//            needToReloadVisibleRowsOnNextAppearance = false
//        }
//    }
//
//    @objc func share(button: UIButton) {
//        if let nav = self.splitViewController?.viewControllers.last as? UINavigationController, let shareable = nav.viewControllers.last as? IssueShareable {
//            shareable.shareIssue(from: button)
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
//
//    @objc func loadIssues() {
//        isLoading = true
//        tableView.reloadEmptyDataSet()
//        issuesDelegate?.didStartLoadingIssues()
//
//        issuesManager.fetchIssues { [weak self] in
//            self?.issuesLoaded(result: $0)
//        }
//
//        contactsManager.fetchContacts(location: UserLocation.current) { result in
//            if case .success(let contacts) = result {
//                self.contacts = contacts
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    private func createViewModelForCategories(issues: [Issue]) -> IssuesViewModel {
//        if shouldShowAllIssues {
//            return AllIssuesViewModel(issues: issues)
//        }
//        return ActiveIssuesViewModel(issues: issues)
//    }
//
//    private func issuesLoaded(result: LoadResult) {
//        isLoading = false
//        lastLoadResult = result
//        issuesDelegate?.didFinishLoadingIssues()
//        if case .success = result {
//            DispatchQueue.global(qos: .background).async { [unowned self] () -> Void in
//                let viewModel = self.createViewModelForCategories(issues: self.issuesManager.issues)
//                DispatchQueue.main.async {
//                    self.viewModel = viewModel
//                    self.tableView.reloadData()
//                }
//            }
//        } else {
//            tableView.reloadEmptyDataSet()
//        }
//        refreshControl?.endRefreshing()
//    }
//
//    private func headerWithTitle(title: String) -> UIView {
//        let notAButton = BorderedButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 26.0))
//        notAButton.setTitle(title, for: .normal)
//        notAButton.setTitleColor(.fvc_darkGray, for: .normal)
//        notAButton.backgroundColor = .fvc_lightGray
//        notAButton.titleLabel?.font = .fvc_header
//        notAButton.borderWidth = 1
//        notAButton.borderColor = .fvc_mediumGray
//        notAButton.topBorder = true
//        notAButton.bottomBorder = true
//        return notAButton
//    }
//
//    @objc func madeCall() {
//        logs = ContactLogs.load()
//        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
//    }
//
//    @objc func willEnterForeground() {
//        loadIssues()
//    }
//
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if identifier == R.segue.issuesViewController.issueSegue.identifier, let split = self.splitViewController {
//            guard let indexPath = tableView.indexPathForSelectedRow else { return true }
//            let controller = R.storyboard.main.issueDetailViewController()!
//            controller.issuesManager = issuesManager
//            controller.issue = viewModel.issueForIndexPath(indexPath: indexPath)
//
//            let nav = UINavigationController(rootViewController: controller)
//            nav.setNavigationBarHidden(true, animated: false)
//            split.showDetailViewController(nav, sender: self)
//            self.iPadShareButton?.isHidden = false
//            return false
//        }
//        return true
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let typedInfo = R.segue.issuesViewController.moreSegue(segue: segue) {
//            typedInfo.destination.issuesManager = issuesManager
//            typedInfo.destination.contactsManager = contactsManager
//        }
//        guard let indexPath = tableView.indexPathForSelectedRow else { return }
//        if let typedInfo = R.segue.issuesViewController.issueSegue(segue: segue) {
//            typedInfo.destination.issuesManager = issuesManager
//            typedInfo.destination.contactsManager = contactsManager
//            typedInfo.destination.issue = viewModel.issueForIndexPath(indexPath: indexPath)
//        }
//    }
//
//    // MARK: - UITableViewDataSource
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return viewModel.numberOfSections()
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Display 'more issues' row in the last section, if we are showing 'active' issues only.
//        let isLastSection = (viewModel.numberOfSections() - 1 == section)
//        let moreIssuesRow = (isLastSection && !shouldShowAllIssues) ? 1 : 0
//
//        return viewModel.numberOfRowsInSection(section: section) + moreIssuesRow
//    }
//
//    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        tableView.rowHeight
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        let issue = viewModel.issueForIndexPath(indexPath: indexPath)
//
////        return 95.0
//        UITableView.automaticDimension
//    }
//
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let title = viewModel.titleForHeaderInSection(section: section)
//        return headerWithTitle(title: title)
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if !shouldShowAllIssues && UIDevice.current.userInterfaceIdiom == .pad {
//            return 0
//        }
//        return 35.0
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard indexPath.row < viewModel.numberOfRowsInSection(section: indexPath.section) else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.moreIssuesCell, for: indexPath)!
//            return cell
//        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.issueCell, for: indexPath)!
//        let issue = viewModel.issueForIndexPath(indexPath: indexPath)
//        cell.titleLabel.text = issue.name
//
//        let issueContacts = (contacts ?? []).filter {
//            issue.contactAreas.contains($0.area)
//        }
//
//        var numContactsContacted = 0
//        for contact in issueContacts {
//            if let contacted = logs?.hasContacted(contactId: contact.id, forIssue: issue.id) {
//                if contacted {
//                    numContactsContacted = numContactsContacted + 1
//                }
//            }
//        }
////        // avoid NaN problem if there are no contacts
//        let progress = issueContacts.count < 1 ? 0.0 : Double(numContactsContacted) / Double(issueContacts.count)
//        cell.progressView.progress = progress
//
//        return cell
//    }
//
//}

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
    
    private func appropriateErrorMessage(for result: LoadResult) -> String {
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
                                    NSAttributedString.Key.font: UIFont.fvc_body
                ])
    }
    
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
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
