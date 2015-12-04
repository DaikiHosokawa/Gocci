//
//  FacebookSharing.swift
//  Gocci
//
//  Created by Markus Wanke on 16.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import FBSDKShareKit




@objc class FacebookSharing: NSObject {
    
    let fromViewController: UIViewController
    let dummyDelegate = FaceBookShareDelegateDummyWrapper()


    var onSuccess: ((facebookPostID: String)->Void)? = nil
    var onFailure: ((error: FacebookSharingError)->Void)? = nil
    var onCancel: (()->Void)? = nil
    
    enum FacebookSharingError: ErrorType {
        case ERROR_FACEBOOK_API(String)
        case ERROR_NETWORK(String)
        case ERROR_AUTHENTICATION
    }
    


    init(fromViewController: UIViewController) {
        self.fromViewController = fromViewController
    }

    
    class FaceBookShareDelegateDummyWrapper: NSObject, FBSDKSharingDelegate {
        
        var master: FacebookSharing? // we use a automatic referene counting hack here. do not turn this into 'weak' or 'unowned'!

        func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
            let postid = (results as? [String:String])?["postId"]
            master?.onSuccess?(facebookPostID: postid ?? "dialog share = no post id")
            //master = nil // breaks the strong reference cycle and releases both this instane and the master
        }
        func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
            master?.onFailure?(error: .ERROR_FACEBOOK_API(error.localizedDescription))
            //master = nil // breaks the strong reference cycle and releases both this instane and the master
        }
        func sharerDidCancel(sharer: FBSDKSharing!) {
            master?.onCancel?()
            //master = nil // breaks the strong reference cycle and releases both this instane and the master
        }
    }

    
    // TODO title
    // the thumbnail does not work, not my fault, facebooks fault. They don't support their own API...
    func shareVideoOnFacebook(fbtoken: String, localVideoFileURL: NSURL, description: String, thumbnail: NSURL?) {
        
        // copies the behaviour of:
        // curl -F "access_token=$TOKEN" -F 'source=@videofile.mp4' -F "description=" 'https://graph-video.facebook.com/me/videos'

        let url = NSURL(string: "https://graph-video.facebook.com/me/videos")!
        
        guard let rawVideoData = NSData(contentsOfURL: localVideoFileURL) else {
            onFailure?(error: .ERROR_FACEBOOK_API("Could not open video file and turn it into NSData"))
            return
        }
        
        var rawThumbData: NSData? = nil
        if thumbnail != nil {
            rawThumbData = NSData(contentsOfURL: thumbnail!)
        }
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST"
        request.HTTPShouldHandleCookies = false
        
        
        /* HAS TO LOOK LIKE THIS:
        
        --------------------------a2ecb5ac777fef89
        Content-Disposition: form-data; name="access_token"

        CAAJkM7KbcYYBA......
        --------------------------a2ecb5ac777fef89
        Content-Disposition: form-data; name="source"; filename="twosec.mp4"
        Content-Type: application/octet-stream

        VIDEO_DATA
        --------------------------a2ecb5ac777fef89
        Content-Disposition: form-data; name="description"

        Test 13918
        --------------------------a2ecb5ac777fef89--
        */
        let formdata = ServiceUtil.FormData()
        request.setValue("multipart/form-data; boundary=" + formdata.boundary, forHTTPHeaderField: "Content-Type")

        formdata.appendDisposition(name: "access_token", value: fbtoken)
        formdata.appendFileDisposition(name: "source", filename: "gocci.mp4", data: rawVideoData)
        if rawThumbData != nil {
            formdata.appendFileDisposition(name: "thumb", filename: "thumb.jpg", data: rawThumbData!)
        }
        
        formdata.appendDisposition(name: "description", value: description)
        
        request.HTTPBody = formdata.generateRequestBody()
        request.setValue(String(request.HTTPBody!.length), forHTTPHeaderField: "Content-Length")
        
        ServiceUtil.performRequest(request,
            onSuccess: { (statusCode, data) -> () in
                if statusCode == 200 {
                    self.onSuccess?(facebookPostID: JSON(data:data)["id"].string ?? "json response did not contain a fb post id")
                }
                else if statusCode == 400 && JSON(data: data)["error"]["code"].intValue == 190 {
                    self.onFailure?(error: .ERROR_AUTHENTICATION)
                }
                else {
                 //   print(JSON(data: data).rawString() ?? "json unparseable")
                    let fberr = JSON(data: data)["error"]["message"].string ?? "no error message"
                    self.onFailure?(error: .ERROR_FACEBOOK_API("HTTP Code: \(statusCode). FACEBOOK ERROR: \(fberr)"))
                }
            },
            onFailure: { errorMessage in
                self.onFailure?(error: .ERROR_NETWORK(errorMessage))
            }
        )
        
    }
    

    
    func shareVideoOnFacebookIndirect(mp4URL mp4URL: String, title: String, description: String) {
        
        let honban = { ()->Void in
            let params = [
                "title": title,
                "description": description,
                "file_url": mp4URL,
//                    "source": data
            ]
            
//            if let thumbnailURL = thumbnailURL{
//                params["thumb"] = thumbnailURL
//            }
            
            
            // API reference: https://developers.facebook.com/docs/graph-api/video-uploads
            let rq = FBSDKGraphRequest(graphPath: "me/videos", parameters: params, HTTPMethod: "POST")
            
            rq.startWithCompletionHandler { (conn, result, error) -> Void in
                if error != nil {
                    self.onFailure?(error: .ERROR_FACEBOOK_API(error.localizedDescription))
                }
                else {
                    let postid = (result as? [String:String])?["id"]
                    self.onSuccess?(facebookPostID: postid ?? "Posting successful, but no postid")
                }
            }
            
        }
        
        FacebookAuthentication.loginWithFacebookWithPublishRightsIfNeeded(fromViewController) { (res) -> Void in
            switch res {
            case .FB_LOGIN_CANCELED:
                self.onCancel?()
            case .FB_PROVIDER_FAIL:
                self.onFailure?(error: .ERROR_NETWORK("Facebook Down"))
            case .FB_LOGIN_SUCCESS:
                honban()
            }
        }
    }
    
    private func prepareFacebookStoryPost(clickURL: String, _ thumbURL: String, _ mp4URL:String, _ title:String, _ description: String) -> FBSDKShareOpenGraphContent {
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

        FacebookAuthentication.loginWithFacebookIfNeeded(fromViewController) {
            switch $0 {
            case .FB_LOGIN_CANCELED:
                self.onCancel?()
            case .FB_PROVIDER_FAIL:
                self.onFailure?(error: .ERROR_NETWORK("Facebook Down"))
            case .FB_LOGIN_SUCCESS:
                let shareDialog = FBSDKShareDialog()
                shareDialog.shareContent = self.prepareFacebookStoryPost(clickURL, thumbURL, mp4URL, title, description)
                self.dummyDelegate.master = self // keeps this and the dummy in memory until the delegate call (ARC hack)
                shareDialog.delegate = self.dummyDelegate
                shareDialog.fromViewController = self.fromViewController
                shareDialog.show()
            }
        }
    }
    
    /// Needs publish_action rights
    func shareGocchiVideoStoryOnFacebookDirect(clickURL clickURL: String, thumbURL: String, mp4URL:String, title:String, description: String) {
        
        FacebookAuthentication.loginWithFacebookWithPublishRightsIfNeeded(fromViewController) {
            switch $0 {
            case .FB_LOGIN_CANCELED:
                self.onCancel?()
            case .FB_PROVIDER_FAIL:
                self.onFailure?(error: .ERROR_NETWORK("Facebook Down"))
            case .FB_LOGIN_SUCCESS:
                let shareAPI = FBSDKShareAPI()
                self.dummyDelegate.master = self // keeps this and the dummy in memory until the delegate call (ARC hack)
                shareAPI.delegate = self.dummyDelegate
                shareAPI.shareContent = self.prepareFacebookStoryPost(clickURL, thumbURL, mp4URL, title, description)
                shareAPI.share()
            }
        }
    }

}