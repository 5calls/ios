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
            return "Why Calling Works"
        case .whoweare:
            return "Who Made 5 Calls"
        }
    }
}

struct WebView: UIViewRepresentable {
    let webViewContent: WebViewContent

    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let path = Bundle.main.path(forResource: "about-\(webViewContent.rawValue)", ofType: "html")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let htmlString = String(data: data, encoding: .utf8)!
        webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
}
