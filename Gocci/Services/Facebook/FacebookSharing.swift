//
//  FacebookSharing.swift
//  Gocci
//
//  Created by Markus Wanke on 16.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import FBSDKShareKit




@ objc class FacebookSharing: NSObject {
    
    
    private enum LoginResult {
        case FB_LOGIN_SUCCESS
        case FB_LOGIN_CANCELED
        case FB_PROVIDER_FAIL
    }
    
    let fromViewController: UIViewController
    let dummyDelegate = FaceBookShareDelegateDummyWrapper()


    var onSuccess: ((fbPostID: String)->Void)? = nil
    var onFailure: ((errorMessage: String)->Void)? = nil
    var onCancel: (()->Void)? = nil
    


    init(fromViewController: UIViewController) {
        self.fromViewController = fromViewController
    }


    deinit { print("sharer deallocated, you fine with this?") }
    

    
    class FaceBookShareDelegateDummyWrapper: NSObject, FBSDKSharingDelegate {
        
        var master: FacebookSharing? // we use a automatic referene counting hack here. do not turn this into 'weak' or 'unowned'!

        func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
            let postid = (results as? [String:String])?["postId"]
            master?.onSuccess?(fbPostID: postid ?? "dialog share = no post id")
            //master = nil // breaks the strong reference cycle and releases both this instane and the master
        }
        func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
            master?.onFailure?(errorMessage: error.localizedDescription)
            //master = nil // breaks the strong reference cycle and releases both this instane and the master
        }
        func sharerDidCancel(sharer: FBSDKSharing!) {
            master?.onCancel?()
            //master = nil // breaks the strong reference cycle and releases both this instane and the master
        }
        
        deinit { print("DUMMY deallocated, you fine with this?") }
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
    
    
    
    // Normal no  login (you can't publish with that)
    private func shareLoginWithFacebookIfNeeded(and:(LoginResult)->Void) {
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
    private func shareLoginWithFacebookWithPublishRightsIfNeeded(and:(LoginResult)->Void) {
        
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
    
    private func upgradeBlock(res: LoginResult) {
        switch res {
        case LoginResult.FB_LOGIN_CANCELED:
            self.onCancel?()
        case LoginResult.FB_PROVIDER_FAIL:
            self.onFailure?(errorMessage: "ERROR: Facebook Down")
        case LoginResult.FB_LOGIN_SUCCESS:
            self.onSuccess?(fbPostID: "no id")
        }
    }
    
    func upgradeFacebookTokenToDefaultRights() {
        self.shareLoginWithFacebookIfNeeded(upgradeBlock)
    }
    
    func upgradeFacebookTokenToPublishRights() {
        self.shareLoginWithFacebookWithPublishRightsIfNeeded(upgradeBlock)
    }
    

    
    func shareVideoOnFacebook(mp4URL mp4URL: String, title: String, description: String, thumbnailURL:String? = nil) {
        
        let honban = { ()->Void in
            var params = [
                "title": title,
                "description": description,
                "file_url": mp4URL,
                // "source": use this if you want to upload from the app direct. must be encoded video data (encoding: form-data)
            ]
            
            if let thumbnailURL = thumbnailURL{
                params["thumb"] = thumbnailURL
            }
            
            
            // API reference: https://developers.facebook.com/docs/graph-api/video-uploads
            let rq = FBSDKGraphRequest(graphPath: "me/videos", parameters: params, HTTPMethod: "POST")
            
            rq.startWithCompletionHandler { (conn, result, error) -> Void in
                if error != nil {
                    self.onFailure?(errorMessage: error.localizedDescription)
                }
                else {
                    let postid = (result as? [String:String])?["id"]
                    self.onSuccess?(fbPostID: postid ?? "Posting successful, but no postid")
                }
            }
            
        }
        
        self.shareLoginWithFacebookWithPublishRightsIfNeeded { (res) -> Void in
            switch res {
            case LoginResult.FB_LOGIN_CANCELED:
                self.onCancel?()
            case LoginResult.FB_PROVIDER_FAIL:
                self.onFailure?(errorMessage: "ERROR: Facebook Down")
            case LoginResult.FB_LOGIN_SUCCESS:
                honban()
            }
        }
    }
    
    private func prepareFacebookDialogPost(clickURL: String, _ thumbURL: String, _ mp4URL:String, _ title:String, _ description: String) -> FBSDKShareOpenGraphContent {
        let properties = [
            "og:type": "video.other",
            "og:title": title,
            "og:description": description,
            "og:url": clickURL,
            "og:video": mp4URL,
            "og:image": thumbURL,
            "og:locale": "ja_JP", // TODO [[NSLocale preferredLanguages] objectAtIndex:0];
            "og:site_name": "Gocci",

            "al:ios" : "aaaaaaaaa",
            "al:iphone" : "bbbbbbbbbbb",
            "al:ipad" : "ccccccccccc",
            "al:android" : "dddddddd",
            "al:web" : "eeeeeeeeeee",
        ]
        
        let object = FBSDKShareOpenGraphObject(properties: properties)
        let action = FBSDKShareOpenGraphAction(type: FACEBOOK_STORY_ACTION_ID, object: object, key: "other")
        
        // this posts direct to the timeline and not the activity log. needs a special checkbox in open grapf options -> actions
        action.setString("true", forKey: "fb:explicitly_shared")
        
        let content = FBSDKShareOpenGraphContent()
        content.action = action;
        content.previewPropertyName = "other";
        
        return content
    }
    
    /// Does not need publish_action rights
    func shareGocchiVideoStoryOnFacebookWithDialog(clickURL clickURL: String, thumbURL: String, mp4URL:String, title:String, description: String) {

        self.shareLoginWithFacebookIfNeeded() {
            switch $0 {
            case LoginResult.FB_LOGIN_CANCELED:
                self.onCancel?()
            case LoginResult.FB_PROVIDER_FAIL:
                self.onFailure?(errorMessage: "ERROR: Facebook Down")
            case LoginResult.FB_LOGIN_SUCCESS:
                let shareDialog = FBSDKShareDialog()
                shareDialog.shareContent = self.prepareFacebookDialogPost(clickURL, thumbURL, mp4URL, title, description)
                self.dummyDelegate.master = self // keeps this and the dummy in memory until the delegate call (ARC hack)
                shareDialog.delegate = self.dummyDelegate
                shareDialog.fromViewController = self.fromViewController
                shareDialog.show()
            }
        }
    }
    
    /// Needs publish_action rights
    func shareGocchiVideoStoryOnFacebookDirect(clickURL clickURL: String, thumbURL: String, mp4URL:String, title:String, description: String) {
        
        self.shareLoginWithFacebookWithPublishRightsIfNeeded {
            switch $0 {
            case LoginResult.FB_LOGIN_CANCELED:
                self.onCancel?()
            case LoginResult.FB_PROVIDER_FAIL:
                self.onFailure?(errorMessage: "ERROR: Facebook Down")
            case LoginResult.FB_LOGIN_SUCCESS:
                let shareAPI = FBSDKShareAPI()
                self.dummyDelegate.master = self // keeps this and the dummy in memory until the delegate call (ARC hack)
                shareAPI.delegate = self.dummyDelegate
                shareAPI.shareContent = self.prepareFacebookDialogPost(clickURL, thumbURL, mp4URL, title, description)
                shareAPI.share()
            }
        }
    }

}