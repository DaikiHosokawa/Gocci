//
//  SNSUtil.swift
//  Gocci
//
//  Created by Ma Wa on 24.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

class SNSUtil
{
    class func loginWithTwitter(currentViewController: UIViewController, andThen:(Bool)->Void)
    {
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
        {
            (success) -> Void in
            
            if !success {
                andThen(false)
                return
            }
            
            let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
            let pic = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username, andSize: FHSTwitterEngineImageSizeOriginal)
            let token = FHSTwitterEngine.sharedEngine().cognitoFormat()
            print("=== Twitter name:   \(username)")
            print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
            print("=== Twitter avatar: \(pic)")
            print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
            
            let iid = AWS.getIIDforRegisterdSNSProvider(TWITTER_PROVIDER_STRING, SNSToken: token)
            
            NetOp.loginWithIID(iid, andThen:
            {
                (code, emsg) -> Void in
                
                andThen(code != NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD)
                
            })
            
        })
        
        currentViewController.presentViewController(vc, animated: true, completion: nil)
    }
}