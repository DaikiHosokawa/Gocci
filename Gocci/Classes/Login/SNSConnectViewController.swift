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

    @IBAction func facebookConnectClicked(sender: AnyObject) {
        SNSUtil.singelton.connectWithFacebook { (result) -> Void in
            switch result {
                case .SNS_CONNECTION_SUCCESS:
                    break
                case .SNS_CONNECTION_UNKNOWN_FAILURE:
                    break
                case .SNS_CONNECTION_CANCELED:
                    break
                case .SNS_PROVIDER_FAIL:
                    break
            }
            print("=== RESUTLT: \(result)")
        }
    }
    
    @IBAction func twitterConnectClicked(sender: AnyObject) {
        SNSUtil.singelton.connectWithTwitter(self) { (result) -> Void in
            switch result {
                case .SNS_CONNECTION_SUCCESS:
                    break
                case .SNS_CONNECTION_UNKNOWN_FAILURE:
                    break
                case .SNS_CONNECTION_CANCELED:
                    break
                case .SNS_PROVIDER_FAIL:
                    break
            }
            print("=== RESUTLT: \(result)")
        }
    }
    
    @IBAction func nashideClicked(sender: AnyObject) {
        // TODO Segue better?
        //self.performSegueWithIdentifier("goTimeline", sender: self)
        
        let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("timeLineEntry")
        self.presentViewController(tutorialViewController, animated: true, completion: nil)
    }
}