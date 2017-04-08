//
//  FacebookPopup.swift
//  Gocci
//
//  Created by Ma Wa on 15.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation



@objc class FacebookPopupBridge: NSObject {
    class func pop(from: UIViewController, initialText: String) {
        let tp = FacebookPopup(from: from, title: "Facebook", widthRatio: 80, heightRatio: 40)
        tp.entryText = initialText
        tp.pop()
    }
    
}

class FacebookPopup: AbstractPopup {
    
    @IBOutlet weak var textView: UITextView!
    
    var entryText: String!
    
    @IBAction func insertRestNameClicked(sender: AnyObject) {
        if VideoPostPreparation.postData.rest_name != "" {
            let restname = VideoPostPreparation.postData.rest_name.stringByReplacingOccurrencesOfString(" ", withString: "")
            textView.text = textView.text + "#" + restname
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
        self.dismiss()
    }
    
    
}
