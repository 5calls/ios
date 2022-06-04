//
//  AboutHtmlViewController.swift
//  FiveCalls
//
//  Created by Alex on 2/6/17.
//  Copyright © 2017 5calls. All rights reserved.
//

import Foundation
import UIKit
//import CPDAcknowledgements
import WebKit

class AboutHtmlViewController : UIViewController {
    
    @IBOutlet weak var contentView: WKWebView!
    var contentName: String { get { return "" } }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let path = Bundle.main.path(forResource: "about-\(contentName)", ofType: "html")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let htmlString = String(data: data, encoding: .utf8)!
        contentView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        contentView.navigationDelegate = self
    }
}

extension AboutHtmlViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch navigationAction.navigationType {
        case .linkActivated:
            // Open links in Safari
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            AnalyticsManager.shared.trackEvent(withName: "Action: Open External Link", andProperties: ["url":url.absoluteString])
            UIApplication.shared.open(url)
            
            decisionHandler(.cancel)
        default:
            // Handle other navigation types...
            decisionHandler(.allow)
        }
    }
}

class WhyCallViewController : AboutHtmlViewController {
    override var contentName: String { get { return "whycall" } }
}

class WhoWeAreViewController : AboutHtmlViewController {
    override var contentName: String { get { return "whoweare" } }
}

