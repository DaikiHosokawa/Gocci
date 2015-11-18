//
//  TwitterAuthentication.swift
//  Gocci
//
//  Created by Ma Wa on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials
//https://dev.twitter.com/rest/reference/get/account/verify_credentials


class TwitterAuthentication {
    
    struct Token {
        var user_key: String
        var user_secret: String
        var gocci_key: String { return TWITTER_CONSUMER_KEY }
        var gocci_secret: String { return TWITTER_CONSUMER_SECRET }
        
        init(key: String, secret: String) {
            user_key = key
            user_secret = secret
        }
    }
    
    static var token: TwitterAuthentication.Token? = nil
    
    class func sessionIsReadyToInteract() -> Bool {
        return false
    }
    
    
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