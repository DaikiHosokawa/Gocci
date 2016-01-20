//
//  SNSConnectViewController.swift
//  Gocci
//
//  Created by Ma Wa on 25.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

import UIKit

class SNSConnectViewController : UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var twitterButton: UIButton!
    
    @IBOutlet weak var continueButtonCaption: UIButton!
    
    var facebookConnectionSuccessful: Bool = false
    var twitterConnectionSuccessful: Bool = false

    
    
    @IBAction func facebookConnectClicked(sender: AnyObject) {
        
        FacebookAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("Facebook連携が現在実施できません。大変申し訳ありません。")
                return
            }
            
            let req = API4.set.sns_link()
            
            req.parameters.provider = FACEBOOK_PROVIDER_STRING
            req.parameters.sns_token = token.cognitoFormat()
            
            req.onAnyAPIError {
                self.simplePopup("ERROR", "連携に失敗しました。アカウント情報を再度お確かめください。", "OK")
            }
            
            req.perform {
                Persistent.user_is_connected_via_facebook = true
                self.simplePopup("成功", "Facebook連携が完了しました", "OK")
                self.facebookConnectionSuccessful = true
                self.facebookButton.enabled = false
                self.transit()
            }
        }
    }

    @IBAction func twitterConnectClicked(sender: AnyObject) {
        
        TwitterAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("Twitter連携が現在実施できません。大変申し訳ありません。")
                return
            }
            
            let req = API4.set.sns_link()
            
            req.parameters.provider = TWITTER_PROVIDER_STRING
            req.parameters.sns_token = token.cognitoFormat()
            
            req.onAnyAPIError {
                self.simplePopup("ERROR", "連携に失敗しました。アカウント情報を再度お確かめください。", "OK")
            }
            
            req.perform {
                Persistent.user_is_connected_via_twitter = true
                self.simplePopup("成功", "Twitter連携が完了しました", "OK")
                self.twitterConnectionSuccessful = true
                self.twitterButton.enabled = false
                self.transit()
            }
        }
    }
    
    func transit() {
        if twitterConnectionSuccessful && facebookConnectionSuccessful {
            let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
            self.presentViewController(tutorialViewController, animated: true, completion: nil)
        }
        else if twitterConnectionSuccessful {
            continueButtonCaption.setTitle("Facebook連携なしで始める", forState: UIControlState.Normal)
        }
        else if facebookConnectionSuccessful {
            continueButtonCaption.setTitle("Twitter連携なしで始める", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func nashideClicked(sender: AnyObject) {
        // TODO Segue better?
        //self.performSegueWithIdentifier("goTimeline", sender: self)
        
        let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
        self.presentViewController(tutorialViewController, animated: true, completion: nil)
    }
}