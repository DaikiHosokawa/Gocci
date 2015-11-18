//
//  TwitterSharing.swift
//  Gocci
//
//  Created by Markus Wanke on 06.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

class TwitterSharing {
    
    let fromViewController: UIViewController
    let key: String
    let secret: String
    
    enum TwitterSharingError: ErrorType {
        case ERROR_VIDEO_FILE_IO(String)
        case ERROR_NETWORK(String)
        case ERROR_TWITTER_API(String)
        case ERROR_TWEET_MESSAGE_OVER_140(String)
    }

    
    var onSuccess: ((twitterPostID: String)->Void)? = nil
    var onFailure: ((error: TwitterSharingError)->Void)? = nil
    
    private var finalSuccedCallback: ((mediaID: String)->Void)? = nil
    
    init(fromViewController: UIViewController) {
        self.fromViewController = fromViewController
        
        // TODO test if FHSTwitterEngine is logged in!
        key = FHSTwitterEngine.sharedEngine().accessToken.key
        secret = FHSTwitterEngine.sharedEngine().accessToken.secret
    }
    
    // if return value is negative -> you cant tweet!
    func videoTweetMessageRemainingCharacters(msg: String) -> Int {
        // every video tweets message text is reduced from 140 chars to 140 - " https://t.co/LY8mBtWEXe"  <- a string like this"
        
        let overhead = 25 // " https://t.co/AAABBBCCCDx".length == 25
        
        return 140 - overhead - msg.length
    }
    
    func tweetVideo(localVideoFileURL localVideoFileURL: NSURL, message: String) {
        
        guard videoTweetMessageRemainingCharacters(message) >= 0 else {
            self.onFailure?(error: .ERROR_TWITTER_API("Tweet is over 140 chars. Video tweets need an extra 25 chars :("))
            return
        }
        
        self.videoUploadINIT(localVideoFileURL) { mediaID in
            self.tweetWithMediaIDs(message, mediaMediaIDs: [mediaID])
        }
    }
    
    func tweetMessage(message: String) {
        
        guard message.length <= 140 else {
            self.onFailure?(error: .ERROR_TWITTER_API("Tweet is over 140 chars."))
            return
        }
        
        tweetWithMediaIDs(message, mediaMediaIDs: [])
    }
    
//    func tweetUpTo4Images(message: String, photoMediaIDs: [String]) {
//        tweetWithMediaIDs(message, mediaMediaIDs: photoMediaIDs)
//    }
    

    private func tweetWithMediaIDs(message: String, mediaMediaIDs: [String]) {
        // https://dev.twitter.com/rest/reference/post/statuses/update
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")!
        //let url = NSURL(string: "http://localhost:8080/1.1/statuses/update.json")!
        
        //let pos = "display_coordinates=true&lat=37.7821120598956&long=122.400612831116&
    
        var params = [ "status": message ]
        
        if !mediaMediaIDs.isEmpty {
            params["media_ids"] = ",".join(mediaMediaIDs)
        }

        twitterAPICallURLEncodedFormPOST(url, formdataParameters: params,
            onSucc: { jsonResponse in
                let postID = jsonResponse["id_str"].string
                self.onSuccess?(twitterPostID: postID ?? "post_id_missing")
            },
            onFail: { jsonResponse in
                let emsg = self.twitterErrorJSONtoString(jsonResponse)
                self.onFailure?(error: .ERROR_TWITTER_API(emsg))
            }
        )
    }
    
    private func videoUploadINIT(localVideoFileURL: NSURL, onSucc: String->()) {
        
        finalSuccedCallback = onSucc
        
        // https://dev.twitter.com/rest/public/uploading-media
        let url = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")!
//        let url = NSURL(string: "http://localhost:8080/1.1/statuses/update.json")!

        
        guard let data = NSData(contentsOfURL: localVideoFileURL) else {
            onFailure?(error: .ERROR_VIDEO_FILE_IO("Could not open video file and turn it into NSData"))
            return
        }
        
        let params = [
            "command": "INIT",
            "media_type": "video/mp4",
            "total_bytes": String(data.length),
        ]
        
        twitterAPICallURLEncodedFormPOST(url, formdataParameters: params,
            onSucc: { jsonResponse in
                guard let mediaID = jsonResponse["media_id_string"].string else {
                    self.onFailure?(error: .ERROR_TWITTER_API("Upload success but no media_id in JSON response"))
                    return
                }
                print("INIT sucessfull> media_id: \(mediaID)")
                
                self.videoUploadAPPENDLoop(mediaID, data: data)
            },
            onFail: { jsonResponse in
//                print(jsonResponse.rawString()!)
                let emsg = self.twitterErrorJSONtoString(jsonResponse)
                self.onFailure?(error: .ERROR_TWITTER_API(emsg))
            }
        )
        
    }
    
    
    private func videoUploadFINALIZE(mediaID: String) {
        
        let url = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")!
        
        
        let params = [
            "command": "FINALIZE",
            "media_id": mediaID
        ]
        
        twitterAPICallURLEncodedFormPOST(url, formdataParameters: params,
            onSucc: { jsonResponse in
                self.finalSuccedCallback?(mediaID: mediaID)
            },
            onFail: { jsonResponse in
                let emsg = self.twitterErrorJSONtoString(jsonResponse)
                self.onFailure?(error: .ERROR_TWITTER_API(emsg))
            }
        )
        
    }
    
    
    private func videoUploadAPPENDLoop(mediaID: String, data: NSData) {
        
        let GOMEGABAITO = 1024 * 1024 * 5
        
        guard data.length <= 3 * GOMEGABAITO  else {
            onFailure?(error: .ERROR_VIDEO_FILE_IO("Video file is too large for Twitter. Limit is 15 MB"))
            return
        }
        
        let chunks = data.splitIntoChunksWithSize(GOMEGABAITO)
        
        guard !chunks.isEmpty else {
            onFailure?(error: .ERROR_VIDEO_FILE_IO("Empty Video file results in zero upload chunks"))
            return
        }
        
        videoUploadAPPENDVideoDataChunk(mediaID, segmentIndex: 0, chunks: chunks)
    }

    
    private func videoUploadAPPENDVideoDataChunk(mediaID: String, segmentIndex: Int, var chunks: [NSData]) {
        
        let url = NSURL(string: "https://upload.twitter.com/1.1/media/upload.json")!
//        let url = NSURL(string: "http://localhost:8080/1.1/statuses/update.json")!
        
        twitterAPICallPOSTDataChunk(url, rawData: chunks.removeFirst(), mediaID: mediaID, segmentIndex: segmentIndex,
            onSucc: { jsonResponse in
                if chunks.isEmpty {
                    self.videoUploadFINALIZE(mediaID)
                }
                else {
                    self.videoUploadAPPENDVideoDataChunk(mediaID, segmentIndex: segmentIndex+1, chunks: chunks)
                }
            },
            onFail: { jsonResponse in
                let emsg = self.twitterErrorJSONtoString(jsonResponse)
                self.onFailure?(error: .ERROR_TWITTER_API(emsg))
            }
        )
    }
    
    
    private func twitterAPICallPOSTDataChunk(url: NSURL, rawData: NSData, mediaID: String, segmentIndex: Int,
        onSucc: (jsonResponse: JSON)->(),
        onFail: (jsonResponse: JSON)->())
    {
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST"
        request.HTTPShouldHandleCookies = false
        
        // BODY has to look like this:     (WITH \r\n NEWLINES!!!)
        /*
        ------------kStHtTpReQuEsTbOuNdArY
        Content-Disposition: form-data; name="media"; filename="short_vid.mp4"
        Content-Type: application/octet-stream

        VIDEO FILE CONTENTS UNENCODED !!!
        ------------kStHtTpReQuEsTbOuNdArY
        Content-Disposition: form-data; name="command"

        APPEND
        ------------kStHtTpReQuEsTbOuNdArY
        Content-Disposition: form-data; name="media_id"

        72398472942
        ------------kStHtTpReQuEsTbOuNdArY
        Content-Disposition: form-data; name="segment_index"

        0
        ------------kStHtTpReQuEsTbOuNdArY--
        */
        
        let formdata = ServiceUtil.FormData()
        request.setValue("multipart/form-data; boundary=" + formdata.boundary, forHTTPHeaderField: "Content-Type")
        
        formdata.appendFileDisposition(name: "media", filename: "gocci.mp4", data: rawData)
        formdata.appendDisposition(name: "command", value: "APPEND")
        formdata.appendDisposition(name: "media_id", value: mediaID)
        formdata.appendDisposition(name: "segment_index", value: String(segmentIndex))
        
        request.HTTPBody = formdata.generateRequestBody()
        request.setValue(String(request.HTTPBody!.length), forHTTPHeaderField: "Content-Length")
        
        // TODO test if FHSTwitterEngine is logged in!
        let key = FHSTwitterEngine.sharedEngine().accessToken.key
        let secret = FHSTwitterEngine.sharedEngine().accessToken.secret
        
        let auth = ServiceUtil.createOAuthSignatureHeaderEntry(key, userSecret: secret, HTTPMethod: "POST", baseURL: url, unencodedPOSTParameters: [:])
        
        //print("Authorization: " + auth)
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        ServiceUtil.performRequest(request,
            onSuccess: { (statusCode, data) -> () in
                let handler = (statusCode >= 200 && statusCode < 300) ? onSucc : onFail
                handler(jsonResponse: JSON(data: data))
            },
            onFailure: { errorMessage in
                self.onFailure?(error: .ERROR_NETWORK(errorMessage))
            }
        )
    }
    
    private func makeFormdataStringFromDictonary(dict: [String: String]) -> String {
        // WARNING: The order of the parameters has to be alphabetically!! media_ids BEFORE status!!
        let sortedDict = dict.sort { $0.0 < $1.0 }
        
        let pairs = sortedDict.map { $0.0 + "=" + $0.1.percentEncodingSane() }
        return "&".join(pairs)
    }
    
    private func twitterErrorJSONtoString(json: JSON) -> String {
        // EXPECT {"errors":[{"code":44,"message":"media_ids parameter is invalid."}]}
        var emsgs: [String] = []
        for (_, err):(String, JSON) in json["errors"] {
            if let e = err["message"].string { emsgs.append(e) }
        }
        let res = ", ".join(emsgs)
        
        if !res.isEmpty {
            return res
        }
        
        return json["error"].string ?? json.rawString() ?? "JSON Unparsable"
    }
    
    
    
    
    private func twitterAPICallURLEncodedFormPOST(url: NSURL, formdataParameters: [String: String],
        onSucc: (jsonResponse: JSON)->(),
        onFail: (jsonResponse: JSON)->())
    {
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = "POST"
        request.HTTPShouldHandleCookies = false
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let formdata = makeFormdataStringFromDictonary(formdataParameters)
        
        guard let data = formdata.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
            onFailure?(error: .ERROR_NETWORK("Formdata conversion failed"))
            return
        }
        
        request.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = data
        
        let auth = ServiceUtil.createOAuthSignatureHeaderEntry(key, userSecret: secret, HTTPMethod: "POST", baseURL: url, unencodedPOSTParameters: formdataParameters)
        
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        
        ServiceUtil.performRequest(request,
            onSuccess: { (statusCode, data) -> () in
                let handler = (statusCode >= 200 && statusCode < 300) ? onSucc : onFail
                handler(jsonResponse: JSON(data: data))
            },
            onFailure: { errorMessage in
                self.onFailure?(error: .ERROR_NETWORK(errorMessage))
            }
        )
    }
}