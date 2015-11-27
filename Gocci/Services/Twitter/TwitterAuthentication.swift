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
    
    enum LoginResult {
        case SNS_LOGIN_SUCCESS
        case SNS_LOGIN_UNKNOWN_FAILURE
        case SNS_LOGIN_CANCELED
        case SNS_USER_NOT_REGISTERD
        case SNS_PROVIDER_FAIL
    }
    
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
    
    static var token: TwitterAuthentication.Token? = {
        let key = Persistent.twitter_key
        let sec = Persistent.twitter_secret
        
        if let key = key, sec = sec {
            return Token(key: key, secret: sec)
        }
        
        return nil
    }()
    
    class func authenticadedAndReadyToUse(cb: Bool->()) {
        
        let url = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!
        
//        TwitterLowLevel.performGETRequest(url, parameters: [:],
        TwitterLowLevel.performGETRequest(url, parameters: ["skip_status": "true", "include_entities": "false"],
            onSuccess: { json in
                print(json.rawString() ?? "häh")
                cb(true)
            },
            onFailure: {
                print($0)
                cb(false)
            }
        )
    }
    
    
    // class disconnectFromCognito
    
//    func loginWithTwitter(currentViewController: UIViewController, andThen:(LoginResult)->Void)
//    {
//        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
//            {
//                (success) -> Void in
//                
//                if !success {
//                    andThen(LoginResult.SNS_PROVIDER_FAIL)
//                    return
//                }
//                
//                let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
//                let pic = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username, andSize: FHSTwitterEngineImageSizeOriginal)
//                let token = FHSTwitterEngine.sharedEngine().cognitoFormat()
//                print("=== Twitter name:   \(username)")
//                print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
//                print("=== Twitter avatar: \(pic)")
//                print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
//                
//                self.loginInWithProviderToken(TWITTER_PROVIDER_STRING, token: token, andThen: andThen)
//                
//        })
//        
//        currentViewController.presentViewController(vc, animated: true, completion: nil)
//    }
    
    class func authenticate(currentViewController cvc: UIViewController,
        onSuccess: (token: Token)->(),
        onFailure: ()->())
    {
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler { success in
            
            guard success else {
                onFailure()
                return
            }
            
            let key = FHSTwitterEngine.sharedEngine().getOAuthToken()
            let sec = FHSTwitterEngine.sharedEngine().getOAuthSecret()
            
            Persistent.twitter_key = key
            Persistent.twitter_secret = sec
            Persistent.immediatelySaveToDisk()
            
            token = Token(key: key, secret: sec)
            
            onSuccess(token: token!)
        }
        
        cvc.presentViewController(vc, animated: true, completion: nil)
    }
}




//                let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
//                let pic = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username, andSize: FHSTwitterEngineImageSizeOriginal)
//                let token = FHSTwitterEngine.sharedEngine().cognitoFormat()
//                print("=== Twitter name:   \(username)")
//                print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
//                print("=== Twitter avatar: \(pic)")
//                print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
