//
//  FeedbackPopup.swift
//  Gocci
//
//  Created by Ma Wa on 15.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation




class FeedbackPopup: AbstractPopup {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var thankYouImage: UIImageView!
    @IBOutlet weak var cBut: UIButton!
    @IBOutlet weak var sBut: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        thankYouImage.hidden = true
        thankYouLabel.hidden = true
        thankYouLabel.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        SVProgressHUD.dismiss()

        super.viewWillDisappear(animated)
    }
    
    @IBAction func sendClicked(sender: AnyObject) {
        
        if textView.text == "" {
            return
        }
        
        SVProgressHUD.showWithStatus("送信…")
        
        
        sendButton.enabled = false
        
        let req = API3.set.feedback()
        
        // SHOULD NEVER HAPPEN (well it does happen if the message is over 10000 chars....
        req.onAnyAPIError {
            SVProgressHUD.showErrorWithStatus("失敗!")
            self.dismiss()
        }
        
        req.parameters.feedback = textView.text.replace("\n", withString: " ")
        
        req.perform {
            self.showThankYouWaitAndDismiss()
        }
    }
    
    func showThankYouWaitAndDismiss() {
        
        thankYouImage.hidden = false;
        thankYouLabel.hidden = false;
        textView.hidden = true
        cBut.enabled = false
        sBut.enabled = false
        
        SVProgressHUD.showSuccessWithStatus("成功!")
        
        
        Util.runInBackground {
            Util.sleep(3.0)
            self.dismiss()
        }
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        self.dismiss()
    }
}
