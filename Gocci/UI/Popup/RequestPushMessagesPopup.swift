//
//  RequestPushMessagesPopup.swift
//  Gocci
//
//  Created by Ma Wa on 16.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation




class RequestPushMessagesPopup: AbstractPopup {
    
    @IBOutlet weak var bellImageView: UIImageView!
    
    var onDecline: (()->())? = nil
    var onAllow: (()->())? = nil
    var inAnyCase: (()->())? = nil
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch: UITouch? = touches.first
        if touch?.view == bellImageView {
            
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    @IBAction func onAllow(sender: AnyObject) {
        dismiss()
        onAllow?()
    }
    
    @IBAction func onNotShowAgain(sender: AnyObject) {
        dismiss()
        onDecline?()
    }
    
    override func viewDidDisappear(a: Bool) {
        super.viewDidDisappear(a)
        inAnyCase?()
    }

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        bellImageView.layer.masksToBounds = true;
//        bellImageView.layer.borderColor = UIColor.redColor().CGColor;
//        bellImageView.layer.borderWidth = 2;
//    }
}