//
//  WebViewPopup.swift
//  Gocci
//
//  Created by Ma Wa on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation




class WebViewPopup: AbstractPopup, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
//        webView.frame = self.view.frame.makeScale(widthDiff: -40, heightDiff: 0)
        webView.scalesPageToFit = true
//        self.view.addSubview(web)
        if url != nil {
            webView.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}
