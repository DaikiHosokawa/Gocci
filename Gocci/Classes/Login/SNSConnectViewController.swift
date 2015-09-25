//
//  SNSConnectViewController.swift
//  Gocci
//
//  Created by Ma Wa on 25.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class SNSConnectViewController : UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    
    @IBOutlet weak var twitterButton: UIButton!
    
    @IBOutlet weak var continueButtonCaption: UIButton!
    
    var facebookConnectionSuccessful: Bool = false
    var twitterConnectionSuccessful: Bool = false

    
    
    @IBAction func facebookConnectClicked(sender: AnyObject) {
        SNSUtil.singelton.connectWithFacebook { (result) -> Void in
            switch result {
                case .SNS_CONNECTION_SUCCESS:
                    Util.popup("Facebook連携が完了しました")
                    self.facebookConnectionSuccessful = true
                    self.facebookButton.enabled = false
                    self.transit()
                    break
                case .SNS_CONNECTION_UNKNOWN_FAILURE:
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                    break
                case .SNS_CONNECTION_CANCELED:
                    break
                case .SNS_PROVIDER_FAIL:
                    Util.popup("Facebook連携が現在実施できません。大変申し訳ありません。")
                    break
            }
            print("=== RESUTLT: \(result)")
        }
    }
    
    @IBAction func twitterConnectClicked(sender: AnyObject) {
        SNSUtil.singelton.connectWithTwitter(self) { (result) -> Void in
            switch result {
                case .SNS_CONNECTION_SUCCESS:
                    Util.popup("Twitter連携が完了しました")
                    self.twitterConnectionSuccessful = true
                    self.twitterButton.enabled = false
                    self.transit()
                    break
                
                case .SNS_CONNECTION_UNKNOWN_FAILURE:
                    Util.popup("連携に失敗しました。アカウント情報を再度お確かめください。")
                    break
                case .SNS_CONNECTION_CANCELED:
                    break
                case .SNS_PROVIDER_FAIL:
                    Util.popup("Twitter連携が現在実施できません。大変申し訳ありません。")
                    break
            }
            print("=== RESUTLT: \(result)")
        }
    }
    
    func transit() {
        if twitterConnectionSuccessful && facebookConnectionSuccessful {
            let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
            self.presentViewController(tutorialViewController, animated: true, completion: nil)
        }
        else if twitterConnectionSuccessful {
            continueButtonCaption.setTitle("continue without facebook connection", forState: UIControlState.Normal)
        }
        else if facebookConnectionSuccessful {
            continueButtonCaption.setTitle("continue without twitter connection", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func nashideClicked(sender: AnyObject) {
        // TODO Segue better?
        //self.performSegueWithIdentifier("goTimeline", sender: self)
        
        let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
        self.presentViewController(tutorialViewController, animated: true, completion: nil)
    }
}