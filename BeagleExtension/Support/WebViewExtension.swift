//
//  WebViewExtension.swift
//  TestBeagle
//
//  Created by VTN-MINHPV21 on 10/06/2021.
//

import Foundation
import Beagle
import WebKit

class WebViewExtension: BaseServerDrivenComponent {
    var url: Expression<String>?
    var html: Expression<String>?
    var authorization: String?
    var syntaxToHandleBackNavigate: [String]?
    var onBackNavigate: [Action]?
    var onInit: [Action]?
    var onLoaded: [Action]?
    var onError: [Action]?
    
    enum CodingKeys: String, CodingKey {
        case url
        case html
        case authorization
        case onInit
        case onLoaded
        case onError
        case syntaxToHandleBackNavigate
        case onBackNavigate
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decodeIfPresent(Expression<String>.self, forKey: .url)
        html = try container.decodeIfPresent(Expression<String>.self, forKey: .html)
        authorization = try container.decodeIfPresent(String.self, forKey: .authorization)
        onInit = try container.decodeIfPresent(forKey: .onInit)
        onLoaded = try container.decodeIfPresent(forKey: .onLoaded)
        onError = try container.decodeIfPresent(forKey: .onError)
        syntaxToHandleBackNavigate = try container.decodeIfPresent([String].self, forKey: .syntaxToHandleBackNavigate)
        onBackNavigate = try container.decodeIfPresent(forKey: .onBackNavigate)
        widgetProperties = try WidgetProperties(from: decoder)
    }
    
    override func toView(renderer: BeagleRenderer) -> UIView {
        let webView = WebViewExtensionView(self, renderer: renderer)
        view = webView
        return super.toView(renderer: renderer)
    }
    
    private class WebViewExtensionView: WKWebView, WKNavigationDelegate {
        private var webView: WebViewExtension?
        private var controller: BeagleController?
        private var timer: Timer?
        private var source: String? {
            didSet {
                self.loadRequest()
            }
        }
        private var html: String? {
            didSet {
                self.loadHtml()
            }
        }
        
        init(_ webView: WebViewExtension, renderer: BeagleRenderer) {
            let configuration = WKWebViewConfiguration()
            configuration.allowsPictureInPictureMediaPlayback = true
            super.init(frame: .zero, configuration: configuration)
            self.webView = webView
            self.navigationDelegate = self
            self.controller = renderer.controller
            controller?.execute(actions: self.webView?.onInit, event: "onInit", origin: self)
            renderer.observe(webView.url, andUpdate: \.source, in: self)
            renderer.observe(webView.html, andUpdate: \.html, in: self)
            
            let leftSwipe = UISwipeGestureRecognizer()
            leftSwipe.direction = .left
            leftSwipe.addTarget(self, action: #selector(onGoBack))
            self.addGestureRecognizer(leftSwipe)
            
            let rightSwipe = UISwipeGestureRecognizer()
            rightSwipe.direction = .right
            rightSwipe.addTarget(self, action: #selector(onGoForward))
            self.addGestureRecognizer(rightSwipe)
        }
        
        @objc func onGoBack() {
            if self.canGoBack {
                self.goBack()
            }
        }
        
        @objc func onGoForward() {
            if self.canGoForward {
                self.goForward()
            }
        }
        
        private func loadRequest() {
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false, block: { _ in
                self.controller?.execute(actions: self.webView?.onError, event: "onError", origin: self)
            })
            guard let `source` = source, let url = URL(string: source) else { return }
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20)
            if let authorization = webView?.authorization {
                request.setValue(authorization, forHTTPHeaderField: "Authorization")
            }
            self.load(request)
        }
        
        private func loadHtml() {
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false, block: { _ in
                self.controller?.execute(actions: self.webView?.onError, event: "onError", origin: self)
            })
            guard let `html` = html else { return }
            self.loadHTMLString(html, baseURL: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            timer?.invalidate()
            timer = nil
            controller?.execute(actions: self.webView?.onLoaded, event: "onLoaded", origin: self)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            timer?.invalidate()
            timer = nil
            controller?.execute(actions: self.webView?.onError, event: "onError", origin: self)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
            
            if let url = webView.url?.absoluteString {
                self.webView?.syntaxToHandleBackNavigate?.forEach {
                    if url.lowercased().contains($0.lowercased()) {
                        self.controller?.execute(actions: self.webView?.onBackNavigate, event: "onBackNavigate", origin: self)
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
            
            if let url = webView.url?.absoluteString {
                self.webView?.syntaxToHandleBackNavigate?.forEach {
                    if url.lowercased().contains($0.lowercased()) {
                        self.controller?.execute(actions: self.webView?.onBackNavigate, event: "onBackNavigate", origin: self)
                    }
                }
            }
        }
    }
}
