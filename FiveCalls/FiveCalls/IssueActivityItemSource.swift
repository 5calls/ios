//
//  IssueActivityItemSource.swift
//  FiveCalls
//
//  Created by Alex on 2/4/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import UIKit

class IssueActivityItemSource: NSObject, UIActivityItemSource {
    let issue: Issue
    
    init(issue: Issue) {
        self.issue = issue
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return issue.name
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return "I just called my rep to \(issue.name) — you should too: http://5calls.org/#issue/\(issue.id)?utm_campaign=twshare"
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
}

extension IssueShareable where Self: UIViewController {
    func shareIssue() {
        let activityViewController = UIActivityViewController(activityItems: [IssueActivityItemSource(issue: issue)], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.addToReadingList, .airDrop, .assignToContact, .copyToPasteboard, .openInIBooks, .print, .saveToCameraRoll]
        present(activityViewController, animated: true, completion: nil)
    }
}
