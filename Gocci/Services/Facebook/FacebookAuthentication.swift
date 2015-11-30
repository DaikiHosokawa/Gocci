//
//  FacebookAuthentication.swift
//  Gocci
//
//  Created by Ma Wa on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


// Code from SNSUtil.swift will come here



class FacebookAuthentication {
    
    struct Token {
        var user_token: String
        var gocci_secret: String { return TWITTER_CONSUMER_SECRET }
        
        init(token: String) {
            user_token = token
        }
    }
    
    static var token: FacebookAuthentication.Token? = {
        if let token = Persistent.facebook_token {
            return Token(token: token)
        }
        return nil
    }()
    
    
    enum LoginResult {
        case FB_LOGIN_SUCCESS
        case FB_LOGIN_CANCELED
        case FB_PROVIDER_FAIL
    }
    
    class func enableFullDebugOutput() {
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
    
    class func setTokenDirect(facebookTokenString fbt: String) {
        token = Token(token: fbt)
    }
    
    
    // WARNING. Callback is only called when a connection to Facebook is possible or not token exists.
    // That means in case of no internet or network errors, nothing happens.
    class func authenticadedAndReadyToUse(cb: Bool->()) {
        
        guard token != nil else {
            cb(false)
            return
        }
        
        let url = NSURL(string: "https://graph.facebook.com/me?access_token=\(token!.user_token)")!
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 30.0)
        request.HTTPShouldHandleCookies = false
        
        ServiceUtil.performRequest(request,
            onSuccess: { (statusCode, data) -> () in
                cb(statusCode == 200)
            },
            onFailure: { errorMessage in
                cb(false)
            }
        )
        
    }
    
    
    
//    private func upgradeBlock(res: FacebookAuthentication.LoginResult) {
//        switch res {
//        case .FB_LOGIN_CANCELED:
//            self.onCancel?()
//        case .FB_PROVIDER_FAIL:
//            self.onFailure?(errorMessage: "ERROR: Facebook Down")
//        case .FB_LOGIN_SUCCESS:
//            self.onSuccess?(fbPostID: "no id")
//        }
//    }
//    
//    func upgradeFacebookTokenToDefaultRights() {
//        self.shareLoginWithFacebookIfNeeded(upgradeBlock)
//    }
//    
//    func upgradeFacebookTokenToPublishRights() {
//        self.shareLoginWithFacebookWithPublishRightsIfNeeded(upgradeBlock)
//    }
//    
    
    // Normal no  login (you can't publish with that)
    class func loginWithFacebookIfNeeded(fromViewController:UIViewController, and:(LoginResult)->Void) {
        if FBSDKAccessToken.currentAccessToken() == nil {
            
            FBSDKLoginManager().logInWithReadPermissions(nil, fromViewController: fromViewController) {
                (result, error) -> Void in
                
                if error != nil {
                    and(LoginResult.FB_PROVIDER_FAIL)
                }
                else if result.isCancelled {
                    and(LoginResult.FB_LOGIN_CANCELED)
                }
                else {
                    and(LoginResult.FB_LOGIN_SUCCESS)
                }
            }
        }
        else {
            and(LoginResult.FB_LOGIN_SUCCESS)
        }
    }
    
    // Login with publish permissions. needs facebook review
    class func loginWithFacebookWithPublishRightsIfNeeded(fromViewController:UIViewController, and:(LoginResult)->Void) {
        
        if FBSDKAccessToken.currentAccessToken() == nil || !FBSDKAccessToken.currentAccessToken().hasGranted("publish_actions") {
            
            FBSDKLoginManager().logInWithPublishPermissions(["publish_actions"], fromViewController: fromViewController) {
                (result, error) -> Void in
                
                if error != nil {
                    and(LoginResult.FB_PROVIDER_FAIL)
                }
                else if result.isCancelled {
                    and(LoginResult.FB_LOGIN_CANCELED)
                }
                else {
                    and(LoginResult.FB_LOGIN_SUCCESS)
                }
            }
        }
        else {
            and(LoginResult.FB_LOGIN_SUCCESS)
        }
    }
}

