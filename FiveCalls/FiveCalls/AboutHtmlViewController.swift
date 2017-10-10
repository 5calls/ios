//
//  AboutHtmlViewController.swift
//  FiveCalls
//
//  Created by Alex on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import UIKit
import CPDAcknowledgements
import Crashlytics

class AboutHtmlViewController : UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var contentView: UIWebView!
    var contentName: String { get { return "" } }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Answers.logCustomEvent(withName: "Screen: About \(contentName)")
        let path = Bundle.main.path(forResource: "about-\(contentName)", ofType: "html")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let htmlString = String(data: data, encoding: .utf8)!
        contentView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        contentView.delegate = self
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .linkClicked:
            // Open links in Safari
            guard let url = request.url else { return true }
            Answers.logCustomEvent(withName: "Action: Open External Link", customAttributes: ["url":url.absoluteString])
            UIApplication.shared.open(url)
            
            return false
        default:
            // Handle other navigation types...
            return true
        }
    }
}

class WhyCallViewController : AboutHtmlViewController {
    override var contentName: String { get { return "whycall" } }
}

class WhoWeAreViewController : AboutHtmlViewController {
    override var contentName: String { get { return "whoweare" } }
}

