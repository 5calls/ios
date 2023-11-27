//
//  WebView.swift
//  FiveCalls
//
//  Created by Christopher Selin on 9/25/23.
//  Copyright © 2023 5calls. All rights reserved.
//

import SwiftUI
import WebKit

enum WebViewContent: String {
    case whycall
    case whoweare
    
    var navigationTitle: String {
        switch self {
        case .whycall:
            return R.string.localizable.aboutWebviewTitleWhyCall()
        case .whoweare:
            return R.string.localizable.aboutWebviewTitleWhoWeAre()
        }
    }
}

struct WebView: UIViewRepresentable {
    let webViewContent: WebViewContent
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let path = Bundle.main.path(forResource: "about-\(webViewContent.rawValue)", ofType: "html")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let htmlString = String(data: data, encoding: .utf8)!
        webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            switch navigationAction.navigationType {
            case .linkActivated:
                // Open links in Safari
                guard let url = navigationAction.request.url else {
                    decisionHandler(.allow)
                    return
                }
                UIApplication.shared.open(url)
                
                decisionHandler(.cancel)
            default:
                // Handle other navigation types...
                decisionHandler(.allow)
            }
        }
    }

    func makeCoordinator() -> WebView.Coordinator {
        Coordinator()
    }
}
