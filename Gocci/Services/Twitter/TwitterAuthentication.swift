//
//  TwitterAuthentication.swift
//  Gocci
//
//  Created by Ma Wa on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



class TwitterAuthentication {
    
    
    // class disconnectFromCognito
    
    
    class func authenticateWithTwitter(currentViewController: UIViewController, andThen:(success:Bool, key:String!, secret:String!)->())
    {
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
            {
                (success) -> Void in
                
                if !success {
                    andThen(success:false, key:nil, secret:nil)
                    return
                }
                
                let key = FHSTwitterEngine.sharedEngine().getOAuthToken()
                let sec = FHSTwitterEngine.sharedEngine().getOAuthSecret()
                
                andThen(success:true, key:key, secret:sec)
                
//                let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
//                let pic = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username, andSize: FHSTwitterEngineImageSizeOriginal)
//                let token = FHSTwitterEngine.sharedEngine().cognitoFormat()
//                print("=== Twitter name:   \(username)")
//                print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
//                print("=== Twitter avatar: \(pic)")
//                print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
                
        })
        
        currentViewController.presentViewController(vc, animated: true, completion: nil)
    }
}