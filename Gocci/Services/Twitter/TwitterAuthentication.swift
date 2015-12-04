//
//  TwitterAuthentication.swift
//  Gocci
//
//  Created by Ma Wa on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

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
    
    class func showTwitterLoginWebViewOnlyIfTheUserIsNotAuthenticated(fromViewController vc: UIViewController, onSuccess: Token->()) {
        authenticadedAndReadyToUse { success in
            if !success {
                authenticate(currentViewController: vc, errorHandler: {}) { onSuccess($0) }
            }
        }
    }
    
    
    // class disconnectFromCognito
    

    
    class func authenticate(currentViewController cvc: UIViewController, errorHandler: ()->(), onSuccess: Token->())
    {
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler { success in
            
            guard success else {
                errorHandler()
                return
            }
            
            let key = FHSTwitterEngine.sharedEngine().getOAuthToken()
            let sec = FHSTwitterEngine.sharedEngine().getOAuthSecret()
            
            token = Token(key: key, secret: sec)
            
            authenticadedAndReadyToUse { success in
                if success {
                    Persistent.twitter_key = key
                    Persistent.twitter_secret = sec
                    onSuccess(token!)
                }
                else {
                    errorHandler()
                }
            }
        }
        
        cvc.presentViewController(vc, animated: true, completion: nil)
    }
}



