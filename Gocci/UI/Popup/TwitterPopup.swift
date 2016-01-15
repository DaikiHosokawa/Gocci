//
//  TwitterPopup.swift
//  Gocci
//
//  Created by Ma Wa on 15.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


@objc class TwitterPopupBridge: NSObject {
    class func pop(from: UIViewController, initialTweet: String) {
        let tp = TwitterPopup(from: from, title: "Twitter", widthRatio: 80, heightRatio: 40)
        tp.entryText = initialTweet
        tp.pop()
    }
}

class TwitterPopup: AbstractPopup, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var insertRestNameButton: UIButton!
    
    var entryText: String!
    
    
    
    @IBAction func insertRestNameClicked(sender: AnyObject) {
        if VideoPostPreparation.postData.rest_name != "" {
            textView.text = textView.text + "#" + VideoPostPreparation.postData.rest_name
        }
        textViewDidChange(textView)
    }

    
    
    func textViewDidChange(textView: UITextView) {
        let left = TwitterSharing.videoTweetMessageRemainingCharacters(textView.text)
        
        if left >= 0 {
            
            sendButton.enabled = true
            sendButton.setTitle("投稿 (残り\(left)文字可能)", forState: UIControlState.Normal)
            sendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            
        }
        else {
            sendButton.enabled = false
            sendButton.setTitle("不可\(-left)文字多いです", forState: UIControlState.Disabled)
            sendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textView.delegate = self
        textView.text = entryText
        textViewDidChange(textView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        VideoPostPreparation.postData.twitterTweetMsg = textView.text
        super.viewWillDisappear(animated)
    }
    
    @IBAction func sendClicked(sender: AnyObject) {

        VideoPostPreparation.postData.twitterTweetMsg = textView.text
        VideoPostPreparation.postData.postOnTwitter = true
        
        self.dismiss()
    }
    

}
