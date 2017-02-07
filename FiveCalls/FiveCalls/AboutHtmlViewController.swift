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
            UIApplication.shared.fvc_open(url)
            
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

