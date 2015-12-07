//
//  FacebookAuthentication.swift
//  Gocci
//
//  Created by Markus Wanke on 30.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation




class FacebookAuthentication {
    
    struct Token {
        var user_token: String
        var fbid: String
        
        var gocci_secret: String { return TWITTER_CONSUMER_SECRET }
        
        init?() {
            if Persistent.facebook_token == nil || Persistent.facebook_id == nil {
                return nil
            }
            user_token = Persistent.facebook_token!
            self.fbid = Persistent.facebook_id!
        }
        
        init(token: String, fbid:String) {
            user_token = token
            self.fbid = fbid
        }
        
        func savePersistent() {
            Persistent.facebook_token = user_token
            Persistent.facebook_id = fbid
        }
        
        func cognitoFormat() -> String {
            return self.user_token
        }
    }
    
    static var token: FacebookAuthentication.Token? = Token()
    
    
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
    
    class func getProfileImageURL() -> String? {
        if token == nil { return nil }
        return "http://graph.facebook.com/\(token!.fbid)/picture?width=640&height=640"
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
    
    
    
    
    class func authenticate(currentViewController cvc: UIViewController, and: Token?->())
    {
        authenticadedAndReadyToUse { success in
            
            if success {
                // already logged in and token is usable
                and(token!)
            }
            else {
                // needs login
                pureLoginProcedure(withPublishRights: false, fromViewController: cvc) { token in
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
    
    class func pureLoginProcedure(withPublishRights wpr: Bool, fromViewController: UIViewController, and: Token?->()) {
        FBSDKSettings.setAppID(FACEBOOK_APP_ID)
        
        FBSDKLoginManager().logInWithReadPermissions(wpr ? ["publish_actions"] : nil, fromViewController: fromViewController) {
            (result, error) -> Void in
            
            if error == nil && !result.isCancelled {
                
                token = Token(token: FBSDKAccessToken.currentAccessToken().tokenString, fbid: FBSDKAccessToken.currentAccessToken().userID )
                
                token?.savePersistent()
                    
                and(token)
            }
            else {
                and(nil)
            }
        }
    }
    
    class func loginWithFacebookIfNeeded(fromViewController:UIViewController, and:(LoginResult)->Void) { fatalError()  }

    class func loginWithFacebookWithPublishRightsIfNeeded(fromViewController:UIViewController, and:(LoginResult)->Void) { fatalError()  }
}

















