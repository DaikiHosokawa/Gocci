//
//  FeedbackPopup.swift
//  Gocci
//
//  Created by Ma Wa on 15.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation




class TwitterPopup: AbstractPopup {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    //var sendButtonCallback: (()->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        SVProgressHUD.dismiss()

        super.viewWillDisappear(animated)
    }
    
    @IBAction func sendClicked(sender: AnyObject) {
        SVProgressHUD.show()
        
        sendButton.enabled = false
        
        let req = API3.set.feedback()
        
        // SHOULD NEVER HAPPEN
        req.onAnyAPIError {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        req.parameters.feedback = textView.text.replace("\n", withString: " ")
        
        req.perform {
            // TODO thank you popup msg
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        SVProgressHUD.dismiss()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
