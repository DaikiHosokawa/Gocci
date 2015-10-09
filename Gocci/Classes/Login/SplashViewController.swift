//
//  SplashViewController.swift
//  Gocci
//
//  Created by Markus Wanke on 08.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

class SplashViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO Download an prebuffer first video. warning: you are not logged in here
        
    }
    
        
    override func viewDidAppear(animated: Bool) {

        
        super.viewDidAppear(animated)
        
        let handleNetOpResult: (NetOpResult, String!) -> Void = { (code, msg) -> Void in
            switch code {
            case NetOpResult.NETOP_SUCCESS:
                AWS2.connectToBackEndWithUserDefData().continueWithBlock({ (task) -> AnyObject! in

                    // TODO maybe predownload something here? first video or so

                    Util.sleep(Int(SPLASH_TIME)) {
                        self.performSegueWithIdentifier("goTimeline", sender: self)
                    }
                    return nil
                })
                
                // TODO
            case NetOpResult.NETOP_NETWORK_ERROR:
                break
            case NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD:
                break
            default:
                break
                
            }
        }
        
        
        if let iid = Util.getUserDefString("iid") {            NetOp.loginWithIID(iid, andThen: handleNetOpResult)
        }
        else if let un = Util.getUserDefString("username"), ava = Util.getUserDefString("avatarLink") {
            NetOp.loginWithAPIV2Conversation(un, avatar: ava, andThen: handleNetOpResult)
        }
        else {
            Util.sleep(Int(SPLASH_TIME)) {
                let twc = self.storyboard!.instantiateViewControllerWithIdentifier("Tutorial")
                self.presentViewController(twc, animated: true, completion: nil)
            }
        }

    }
}



