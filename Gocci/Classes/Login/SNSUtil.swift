//
//  SNSUtil.swift
//  Gocci
//
//  Created by Ma Wa on 24.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit

class SNSUtil : NSObject
{
    static let singelton = SNSUtil()
    
    enum LoginResult {
        case SNS_LOGIN_SUCCESS
        case SNS_LOGIN_UNKNOWN_FAILURE
        case SNS_LOGIN_CANCELED
        case SNS_USER_NOT_REGISTERD
        case SNS_PROVIDER_FAIL
    }
    
    enum ConnectionResult {
        case SNS_CONNECTION_SUCCESS
        case SNS_CONNECTION_UNKNOWN_FAILURE
        case SNS_CONNECTION_UN_AUTH
        case SNS_CONNECTION_CANCELED
        case SNS_PROVIDER_FAIL
    }
    
    override init()
    {
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        //FHSTwitterEngine.sharedEngine().setDelegate(self)
        FHSTwitterEngine.sharedEngine().loadAccessToken()
        
        FBSDKSettings.setAppID(FACEBOOK_APP_ID)
    }
    
    class func si() -> SNSUtil {
        return singelton
    }
    

    func connectWithTwitter(currentViewController: UIViewController, andThen:(ConnectionResult)->Void)
    {
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
        {
            (success) -> Void in
            
            if !success {
                andThen(ConnectionResult.SNS_PROVIDER_FAIL)
                return
            }
            
            let username = FHSTwitterEngine.sharedEngine().authenticatedUsername
            let picurl: String? = FHSTwitterEngine.sharedEngine().getProfileImageURLStringForUsername(username,
                andSize: FHSTwitterEngineImageSizeOriginal) as? String
            
            print("=== Twitter name:   \(username)")
            print("=== Twitter auth:   \(FHSTwitterEngine.sharedEngine().authenticatedID)")
            print("=== Twitter avatar: \(picurl)")
            print("=== Cognito format: \(FHSTwitterEngine.sharedEngine().cognitoFormat())")
            
            NSUserDefaults.standardUserDefaults().setValue(picurl, forKey: "avatarLink")
            
            
            APIClient.connectWithSNS(TWITTER_PROVIDER_STRING,
                token: FHSTwitterEngine.sharedEngine().cognitoFormat(),
                profilePictureURL: picurl ?? "none",
                handler:
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    andThen(ConnectionResult.SNS_CONNECTION_UNKNOWN_FAILURE)
                }
                else if result["code"] as! Int == 401 {
                    andThen(ConnectionResult.SNS_CONNECTION_UN_AUTH)
                }
                else if result["code"] as! Int == 200 {
                    andThen(ConnectionResult.SNS_CONNECTION_SUCCESS)
                }
                else {
                    andThen(ConnectionResult.SNS_CONNECTION_UNKNOWN_FAILURE)
                }
                
            })
        })
        
        currentViewController.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    func connectWithFacebook(currentViewController vc: UIViewController, andThen:(ConnectionResult)->Void)
    {
        FBSDKLoginManager().logInWithReadPermissions(nil, fromViewController: vc)
        {
            (result, error) -> Void in
            
            if error != nil {
                andThen(ConnectionResult.SNS_PROVIDER_FAIL)
                return
            }
            else if result.isCancelled {
                andThen(ConnectionResult.SNS_CONNECTION_CANCELED)
                return
            }
            
            print("=== Facebook login success")
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            let fbid = FBSDKAccessToken.currentAccessToken().userID
            
            print("=== FBID: \(fbid)")
            
            let picurl = "http://graph.facebook.com/\(fbid)/picture?width=640&height=640"
            NSUserDefaults.standardUserDefaults().setValue(picurl, forKey: "avatarLink")

            APIClient.connectWithSNS(FACEBOOK_PROVIDER_STRING, token: token, profilePictureURL: picurl, handler:
            {
                (result, code, error) -> Void in
                
                if error != nil || code != 200 {
                    andThen(ConnectionResult.SNS_CONNECTION_UNKNOWN_FAILURE)
                }
                else if result["code"] as! Int == 401 {
                    andThen(ConnectionResult.SNS_CONNECTION_UN_AUTH)
                }
                else if result["code"] as! Int == 200 {
                    andThen(ConnectionResult.SNS_CONNECTION_SUCCESS)
                }
                else {
                    andThen(ConnectionResult.SNS_CONNECTION_UNKNOWN_FAILURE)
                }
            })
        }
    }
    
    func loginWithTwitter(currentViewController: UIViewController, andThen:(LoginResult)->Void)
    {
        let vc = FHSTwitterEngine.sharedEngine().loginControllerWithCompletionHandler(
        {
            (success) -> Void in
            
            if !success {
                andThen(LoginResult.SNS_PROVIDER_FAIL)
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
            
            NetOp.loginWithSNS(iid, andThen:
            {
                (code, emsg) -> Void in
                
                if code == NetOpResult.NETOP_SUCCESS {
                    andThen(LoginResult.SNS_LOGIN_SUCCESS)
                }
                else if code == NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD {
                    andThen(LoginResult.SNS_USER_NOT_REGISTERD)
                }
                else {
                    print("WARNING, should never happen: " + emsg)
                    andThen(LoginResult.SNS_LOGIN_UNKNOWN_FAILURE)
                }
                
            })
            
        })
        
        currentViewController.presentViewController(vc, animated: true, completion: nil)
    }
    

    
    func loginWithFacebook(currentViewController vc: UIViewController, andThen:(LoginResult)->Void)
    {
        // maybe reset the keychain here
        FBSDKLoginManager().logInWithReadPermissions(nil, fromViewController: vc)
        {
            (result, error) -> Void in
            
            if error != nil {
                andThen(LoginResult.SNS_PROVIDER_FAIL)
                return
            }
            else if result.isCancelled {
                andThen(LoginResult.SNS_LOGIN_CANCELED)
                return
            }
            
            print("=== Facebook login success")
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            print("=== Facebook token: \(token)")
            
            let iid = AWS.getIIDforRegisterdSNSProvider(FACEBOOK_PROVIDER_STRING, SNSToken: token)
            
            NetOp.loginWithSNS(iid, andThen:
            {
                (code, emsg) -> Void in
                
                if code == NetOpResult.NETOP_SUCCESS {
                    andThen(LoginResult.SNS_LOGIN_SUCCESS)
                }
                else if code == NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD {
                    andThen(LoginResult.SNS_USER_NOT_REGISTERD)
                }
                else {
                    print("WARNING, should never happen: " + emsg)
                    andThen(LoginResult.SNS_LOGIN_UNKNOWN_FAILURE)
                }
            })
        }
    }
}