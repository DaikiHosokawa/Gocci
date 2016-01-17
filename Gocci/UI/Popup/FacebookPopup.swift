//
//  FacebookPopup.swift
//  Gocci
//
//  Created by Ma Wa on 15.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation



@objc class FacebookPopupBridge: NSObject {
    class func pop(from: UIViewController, initialText: String, cancelFunc: OVF = nil) {
        let tp = FacebookPopup(from: from, title: "Facebook", widthRatio: 80, heightRatio: 40)
        tp.entryText = initialText
        tp.onCancel = cancelFunc
        tp.pop()
    }
    
}

class FacebookPopup: AbstractPopup {
    
    @IBOutlet weak var textView: UITextView!
    
    var onCancel: OVF = nil
    
    var entryText: String!
    var postClicked: Bool = false
    
    override func viewDidDisappear(a: Bool) {
        super.viewDidDisappear(a)
        if !postClicked {
            onCancel?()
        }
    }
    
    @IBAction func insertRestNameClicked(sender: AnyObject) {
        if VideoPostPreparation.postData.rest_name != "" {
            textView.text = textView.text + "#" + VideoPostPreparation.postData.rest_name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = entryText
    }
    
    override func viewWillDisappear(animated: Bool) {
        VideoPostPreparation.postData.facebookTimelineMessage = textView.text
        super.viewWillDisappear(animated)
    }
    
    @IBAction func sendClicked(sender: AnyObject) {
        
        VideoPostPreparation.postData.facebookTimelineMessage = textView.text
        VideoPostPreparation.postData.postOnFacebook = true
        postClicked = true
        
        self.dismiss()
    }
    
    
}
