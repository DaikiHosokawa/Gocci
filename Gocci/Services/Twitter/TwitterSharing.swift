//
//  TwitterSharing.swift
//  Gocci
//
//  Created by Ma Wa on 06.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class TwitterSharing {
    
    let fromViewController: UIViewController

    
    var onSuccess: ((twitterPostID: String)->Void)? = nil
    var onFailure: ((errorMessage: String)->Void)? = nil
    var onCancel: (()->Void)? = nil
    
    init(fromViewController: UIViewController) {
        self.fromViewController = fromViewController
    }
    
    // unlike facebook, this only works with local files
    func shareVideoOnFacebook(mp4URL mp4URL: String, description: String) {

        // TODO CHECK IF LOGGED IN
        // TODO VIDEO UPLAOD
        // TODO tweet
    }
    
    func tweetVideo(message: String, videoMediaID: String) {
        tweetWithMediaIDs(message, mediaMediaIDs: [videoMediaID])
    }
    
    func tweetMessage(message: String) {
        tweetWithMediaIDs(message, mediaMediaIDs: [])
    }
    
    func tweetUpTo4Images(message: String, photoMediaIDs: [String]) {
        tweetWithMediaIDs(message, mediaMediaIDs: photoMediaIDs)
    }

    func tweetWithMediaIDs(message: String, mediaMediaIDs: [String]) {
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")!
        //let url = NSURL(string: "http://localhost:8080/1.1/statuses/update.json")!
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST"
        request.HTTPShouldHandleCookies = false
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // TODO test if FHSTwitterEngine is logged in!
        // https://dev.twitter.com/oauth/overview/authorizing-requests
        FHSTwitterEngine.sharedEngine().signRequest(request)
        
        
        // https://dev.twitter.com/rest/reference/post/statuses/update
        // WARNING: The order of the parameters has to be alphabetically!! media_ids BEFORE status!!
        // WARNING: This is the end of an HTTP POST so it has to end with \r\n
        
        //let pos = "display_coordinates=true&lat=37.7821120598956&long=122.400612831116&
        let med = mediaMediaIDs.isEmpty ? "" : "media_ids=" + ",".join(mediaMediaIDs) + "&"
        
        let body = med + "status=\(message.percentEncodingHTML5Style())\r\n"
        let data = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        request.setValue(String(data!.length), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
        
        
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.allowsCellularAccess = true
        // WARNING! ephemeral means nothing to disk. also NO COOKIES!!
        let session = NSURLSession(configuration: config)
        
        let urlsessiontask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard error == nil else {
                self.onFailure?(errorMessage: "TWITTER: " + (error?.localizedDescription ?? "No error message"))
                return
            }
            
            guard let resp = response as? NSHTTPURLResponse else {
                self.onFailure?(errorMessage: "TWITTER: response is not an HTTP Response")
                return
            }
            
            print("=== Status Code: \(resp.statusCode)")
            
            if resp.statusCode == 200 {
                let postID = JSON(data: data ?? NSData())["id_str"].string
                self.onSuccess?(twitterPostID: postID ?? "post_id_missing")
                print( data!.asUTF8String())
            }
            else if let data = data {
                // EXPECT {"errors":[{"code":44,"message":"media_ids parameter is invalid."}]}
                var emsgs: [String] = []
                for (_, err):(String, JSON) in JSON(data: data)["errors"] {
                    if let e = err["message"].string { emsgs.append(e) }
                }
                self.onFailure?(errorMessage: "TWITTER: " + (emsgs.isEmpty ? data.asUTF8String() : ", ".join(emsgs)))
            }
            else {
                self.onFailure?(errorMessage: "TWITTER: no json data recieved")
            }
        }
    
        urlsessiontask.resume()
        
    }
}