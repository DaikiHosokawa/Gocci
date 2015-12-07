//
//  TwitterAuthentication.swift
//  Gocci
//
//  Created by Ma Wa on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

class TwitterAuthentication {
    
    static var userJSON: JSON? = nil
    
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
        
        init?() {
            if Persistent.twitter_key == nil || Persistent.twitter_secret == nil {
                return nil
            }
            user_key = Persistent.twitter_key!
            user_secret = Persistent.twitter_secret!
        }
        
        init(key: String, secret: String) {
            user_key = key
            user_secret = secret
        }
        
        func cognitoFormat() -> String {
            return self.user_key + ";" + self.user_secret
        }
        
        func savePersistent() {
            Persistent.twitter_key = user_key
            Persistent.twitter_secret = user_secret
        }
    }
    
    static var token: TwitterAuthentication.Token? = Token()
    
    class func authenticadedAndReadyToUse(cb: Bool->()) {
        
        let url = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!
        
        TwitterLowLevel.performGETRequest(url, parameters: ["skip_status": "true", "include_entities": "false"],
            onSuccess: { json in
                //TwitterAuthentication.userJSON = json
                cb(true)
            },
            onFailure: { a in
                print(a)
                cb(false)
            }
        )
    }
    

    
    class func getProfileImageURL() -> String? {
        return userJSON?["profile_image_url"].string
    }
    
    
    // class disconnectFromCognito
    


    
    class func authenticate(currentViewController cvc: UIViewController, and: Token?->())
    {
        authenticadedAndReadyToUse { success in
            
            if success {
                // already logged in and token is usable
                and(token!)
            }
            else {
                // needs login
                pureLoginProcedure(cvc) { token in
                    if token == nil {
                        and(nil)
                        return
                    }
                    
                    // just in case
                    authenticadedAndReadyToUse { success in
                        and( success ? token! : nil )
                    }
                }
            }
        }
    }
    
    
    private class func pureLoginProcedure(cvc: UIViewController, and: Token?->() ) {
            
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler { success in
            
            guard success else {
                and(nil)
                return
            }
            
            let key = FHSTwitterEngine.sharedEngine().getOAuthToken()
            let sec = FHSTwitterEngine.sharedEngine().getOAuthSecret()
            
            token = Token(key: key, secret: sec)
            token?.savePersistent()

            and(token!)
        }
        
        Util.runOnMainThread{
            cvc.presentViewController(vc, animated: true, completion: nil)
        }
    }
}



