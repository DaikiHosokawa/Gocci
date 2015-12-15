//
//  FeedbackPopup.swift
//  Gocci
//
//  Created by Ma Wa on 15.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation




class FeedbackPopup: AbstractPopup {
    
    @IBOutlet weak var webView: UIWebView!
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        webView.delegate = self
//        //        webView.frame = self.view.frame.makeScale(widthDiff: -40, heightDiff: 0)
//        webView.scalesPageToFit = true
//        //        self.view.addSubview(web)
//        if url != nil {
//            webView.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
//        }
    }
    

    
}
