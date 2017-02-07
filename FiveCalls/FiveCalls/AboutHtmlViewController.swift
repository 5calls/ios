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

class AboutHtmlViewController : UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var contentView: UIWebView!
    var contentName: String { get { return "" } }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.tintColor = .white
        
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
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // openURL(_:) is deprecated in iOS 10+.
                UIApplication.shared.openURL(url)
            }
            return false
        default:
            // Handle other navigation types...
            return true
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
//        let cssPath = Bundle.main.path(forResource: "styles", ofType: "css")
//        let javascriptString = "var link = document.createElement('link'); link.href = '\(cssPath)'; link.rel = 'stylesheet'; document.head.appendChild(link)";
//        print(javascriptString)
//        webView.stringByEvaluatingJavaScript(from: javascriptString)
    }
    
}

class WhyCallViewController : AboutHtmlViewController {
    override var contentName: String { get { return "whycall" } }
}

class WhoWeAreViewController : AboutHtmlViewController {
    override var contentName: String { get { return "whoweare" } }
}

