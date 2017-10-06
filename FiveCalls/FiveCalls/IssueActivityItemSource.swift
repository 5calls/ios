//
//  IssueActivityItemSource.swift
//  FiveCalls
//
//  Created by Alex on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit
import Crashlytics

class IssueActivityItemSource: NSObject, UIActivityItemSource {
    let issue: Issue
    
    init(issue: Issue) {
        self.issue = issue
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return issue.name
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType?) -> Any? {
        return R.string.localizable.iJustCalledMyRep(issue.name, issue.id)
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return issue.name
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return nil
    }
}

protocol IssueShareable: class {
    var issue: Issue! { get }
    func shareIssue(from: Any?)
}

extension IssueShareable where Self: UIViewController {
    func shareIssue(from: Any?) {
        Answers.logCustomEvent(withName:"Action: Share Issue", customAttributes: ["issue_id":issue.id])
        let activityViewController = UIActivityViewController(activityItems: [IssueActivityItemSource(issue: issue)], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .openInIBooks, .print, .saveToCameraRoll]

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let button = from as? UIButton {
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceView = button
                activityViewController.popoverPresentationController?.sourceRect = button.bounds
            } else if let item = from as? UIBarButtonItem {
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.barButtonItem = item
            }
        }

        present(activityViewController, animated: true, completion: nil)
    }
}
