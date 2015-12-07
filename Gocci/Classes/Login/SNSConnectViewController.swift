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
            
            APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING,
                token: token.cognitoFormat(),
                profilePictureURL: FacebookAuthentication.getProfileImageURL() ?? "none")
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
                else if result["code"] as! Int == 200 {
                    Persistent.user_is_connected_via_facebook = true
                    Util.popup("Facebook連携が完了しました")
                    self.facebookConnectionSuccessful = true
                    self.facebookButton.enabled = false
                    self.transit()
                }
                else {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
            }
        }
    }

    @IBAction func twitterConnectClicked(sender: AnyObject) {
        
        TwitterAuthentication.authenticate(currentViewController: self) { token in
            
            guard let token = token else {
                Util.popup("Twitter連携が現在実施できません。大変申し訳ありません。")
                return
            }
            
            APIClient.connectWithSNS(TWITTER_PROVIDER_STRING,
                token: token.cognitoFormat(),
                profilePictureURL: TwitterAuthentication.getProfileImageURL() ?? "none")
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
                else if result["code"] as! Int == 200 {
                    Persistent.user_is_connected_via_twitter = true
                    Util.popup("Twitter連携が完了しました")
                    self.twitterConnectionSuccessful = true
                    self.twitterButton.enabled = false
                    self.transit()                }
                else {
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                }
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