//
//  SNSUtil.swift
//  Gocci
//
//  Created by Markus Wanke on 24.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FBSDKShareKit


let SNSUtil = SNSUtilSingelton.sharedInstance

class SNSUtilSingelton : NSObject, FBSDKSharingDelegate
{
    static let sharedInstance = SNSUtilSingelton()
    
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
    
    enum VideoShareResult {
        case SUCCESS
        case FAIL
    }
    
    override init()
    {
        FHSTwitterEngine.sharedEngine().permanentlySetConsumerKey(TWITTER_CONSUMER_KEY, andSecret:TWITTER_CONSUMER_SECRET)
        //FHSTwitterEngine.sharedEngine().setDelegate(self)
        FHSTwitterEngine.sharedEngine().loadAccessToken()
        
        FBSDKSettings.setAppID(FACEBOOK_APP_ID)
        

    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        //print("worked")
     //   print(results)
        NSLog("====== Facebook sharing completed: ", results)
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("failed")
    //    print(error)
//        NSLog("====== Facebook sharing failed: \(error)")
    }
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    
    func enableFullDebugOutput() {
        var logopt = Set<String>()
        logopt.insert(FBSDKLoggingBehaviorAccessTokens)
        logopt.insert(FBSDKLoggingBehaviorAppEvents)
        logopt.insert(FBSDKLoggingBehaviorInformational)
        logopt.insert(FBSDKLoggingBehaviorUIControlErrors)
        logopt.insert(FBSDKLoggingBehaviorGraphAPIDebugWarning)
        logopt.insert(FBSDKLoggingBehaviorGraphAPIDebugInfo)
        logopt.insert(FBSDKLoggingBehaviorNetworkRequests)
        logopt.insert(FBSDKLoggingBehaviorDeveloperErrors)
        FBSDKSettings.setLoggingBehavior(logopt)
    }

    
    func shareVideoOnFacebook(mp4URL: String, title: String, description: String, and:(VideoShareResult, String)->Void) {
        
        // TODO check if logged in
        
        let params = [
            "title": title,
            "description": description,
            // "thumb": ""
            "file_url": mp4URL,
            // "source": use this if you want to upload from the app direct. must be encoded video data (encoding: form-data)
        ]
        
        
        
        // API reference: https://developers.facebook.com/docs/graph-api/video-uploads
        let rq = FBSDKGraphRequest(graphPath: "me/videos", parameters: params, HTTPMethod: "POST")
        
        rq.startWithCompletionHandler { (conn, result, error) -> Void in
            if error != nil {
                NSLog(String(error));
                and(VideoShareResult.FAIL, String(error))
            }
            else {
                NSLog("Post id : " + (result as! [String:String])["id"]!);
                and(VideoShareResult.SUCCESS, (result as! [String:String])["id"]!)
            }
        }
    }
    
    
    func shareGocchiVideoStoryOnFacebook(clickURL: String, thumbURL: String, mp4URL:String, title:String, description: String, dialog:UIViewController? = nil) {

        // TODO check if logged in


        let properties = [
            "og:type": "video.other",
            "og:title": title,
            "og:description": description,
            "og:url": clickURL,
            "og:video": mp4URL,
            "og:image": thumbURL,
            "og:locale": "ja_JP", // TODO [[NSLocale preferredLanguages] objectAtIndex:0];
            "og:site_name": "Gocci",
        ]


//        al:ios
//        IosApplink	Yes	Optional
//        al:iphone
//        IosApplink	Yes	Optional
//        al:ipad
//        IosApplink	Yes	Optional
//        al:android
//        Android	Yes	Optional
//        al:windows_phone
//        Windows Phone	Yes	Optional
//        al:windows
//        Windows	Yes	Optional	
//        al:windows_universal
//        Windows Universal	Yes	Optional	
//        al:web
//        Web	No	Optional	

        
        let object = FBSDKShareOpenGraphObject(properties: properties)
        
        let action = FBSDKShareOpenGraphAction(type: "gocci_test:record", object: object, key: "other")
        action.setString("true", forKey: "fb:explicitly_shared")

        let content = FBSDKShareOpenGraphContent()
        content.action = action;
        content.previewPropertyName = "other";
        
        if dialog == nil {
            let shareAPI = FBSDKShareAPI()
            shareAPI.delegate = self
            shareAPI.shareContent = content
            shareAPI.share()
        }
        else {
            let shareDialog = FBSDKShareDialog()
            shareDialog.shareContent = content
            shareDialog.delegate = self
            shareDialog.fromViewController = dialog
            shareDialog.show()
        }

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
    
    
    
    func loginInWithProviderToken(provider:String, token:String, andThen:(LoginResult)->Void)
    {
        AWSManager.getIIDforSNSLogin(provider, token: token).continueWithBlock { (task) -> AnyObject! in
            if task.result == nil {
                andThen(LoginResult.SNS_USER_NOT_REGISTERD)
                return nil
            }
            
            NetOp.loginWithSNS(task.result as! String, andThen: {
                (code, emsg) -> Void in
                
                if code == NetOpResult.NETOP_SUCCESS {
                    
                    // TODO dirty implementation. Fix this one day
                    let uid: String = Util.getUserDefString("user_id")!
                    let iid: String = Util.getUserDefString("iid")!
                    let tok: String = Util.getUserDefString("token")!
                    
                    AWS2.connectWithBackend(iid, userID: uid, token: tok).continueWithBlock({ (task) -> AnyObject! in
                        andThen(LoginResult.SNS_LOGIN_SUCCESS)
                        AWS2.storeSNSTokenInDataSet(provider, token: token)
                        return nil
                    })
                    
                }
                else if code == NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD {
                    andThen(LoginResult.SNS_USER_NOT_REGISTERD)
                }
                else {
                    print("WARNING, should never happen: " + emsg)
                    andThen(LoginResult.SNS_LOGIN_UNKNOWN_FAILURE)
                }
                
            })
            
            return nil
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
            
            self.loginInWithProviderToken(TWITTER_PROVIDER_STRING, token: token, andThen: andThen)
            
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
            
            self.loginInWithProviderToken(FACEBOOK_PROVIDER_STRING, token: token, andThen: andThen)

        }
    }
}