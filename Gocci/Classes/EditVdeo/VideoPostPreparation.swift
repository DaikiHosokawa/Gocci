//
//  VideoPostPreparation.swift
//  Gocci
//
//  Created by Ma Wa on 09.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

// This file will be gone one day

import Foundation




@objc class VideoPostPreparation: NSObject {
    
    @objc class PostData: NSObject {
        
        var rest_id: String = ""            // NEEDED
        
        var category_id: String = "1"
        var category_string: String = "" { didSet { notifyNewCategory?(category_string) } }
        var value: String = ""           { didSet { notifyNewPrice?(value) } }
        var memo: String = ""
        var cheer_flag: Bool = false
        
        var prepared_restaurant: Bool = true
        var rest_name: String = "" { didSet { notifyNewRestName?(rest_name) } }
        var lat: Double = 0.0
        var lon: Double = 0.0
        
        
        var notifyNewPrice: (String->())? = nil
        var notifyNewCategory: (String->())? = nil
        var notifyNewRestName: (String->())? = nil
        
        var postOnTwitter: Bool = false
        var twitterTweetMsg: String = ""
        var twitterRelativeVideoFilename = ""
        
    }
    
    @objc static var postData = PostData()
    
    class func resetPostData() {
        postData = PostData()
    }
    
    class func isReadyToSend() -> Bool {
        return (postData.prepared_restaurant && postData.rest_name != "") || (!postData.prepared_restaurant && postData.rest_id != "")
    }
    
    
    
    class func initiateUploadTaskChain(videoFileInTMPFolder: NSURL) {
        
        let timestamp = Util.timestampUTC()
        
        let relativeVideoFilePath = saveVideoInDocumentsAndCleanUpVideoFragments(videoFileInTMPFolder, timestamp: timestamp)
        
        
        print("========================================================")
        print("STARTING THE VIDEO UPLAOD TASK CHAIN")
        print("TYPE: " + (postData.prepared_restaurant ? "With new Retaurant" : "With retaurant from GPS list" ))
        print("========================================================")
        
        if postData.prepared_restaurant {
            GocciAddRestaurantTask(
                restName: postData.rest_name,
                lat: postData.lat,
                lon: postData.lon,
                timestamp: timestamp,
                userID: Persistent.user_id!,
                cheerFlag: postData.cheer_flag,
                kakaku: postData.value,
                categoryID: postData.category_id,
                comment: postData.memo,
                videoFilePath: relativeVideoFilePath).schedule()
        }
        else {
            GocciVideoSharingTask(
                timestamp: timestamp,
                userID: Persistent.user_id!,
                restaurantID: postData.rest_id,
                cheerFlag: postData.cheer_flag,
                kakaku: postData.value,
                categoryID: postData.category_id,
                comment: postData.memo,
                videoFilePath: relativeVideoFilePath).schedule()
        }
        
        if postData.postOnTwitter {
            TwitterVideoSharingTask(tweetMessage: postData.twitterTweetMsg, relativeFilePath: postData.twitterRelativeVideoFilename).schedule()
        }
        
        resetPostData()
    }
    
    
    class func saveVideoInDocumentsAndCleanUpVideoFragments(newVideoFile: NSURL, timestamp: String) -> String {
        
        let fm = NSFileManager.defaultManager()
        
        try! fm.createDirectoryAtURL(NSFileManager.postedVideosDirectory(), withIntermediateDirectories: true, attributes: nil)
        
        let relative = POSTED_VIDEOS_DIRECTORY + "/" + timestamp + ".mp4"
        let absolut  = NSFileManager.appRootDirectory().URLByAppendingPathComponent(relative)
        
        print("relative \(relative)")
        print("absolut \(absolut)")
        
        try! fm.linkItemAtURL(newVideoFile, toURL: absolut)
        
        if postData.postOnTwitter {
            let twit_relative = "Library" + "/" + timestamp + "_for_twitter.mp4"
            let twit_absolut  = NSFileManager.appRootDirectory().URLByAppendingPathComponent(twit_relative)
            
            postData.twitterRelativeVideoFilename = twit_relative
            try! fm.linkItemAtURL(newVideoFile, toURL: twit_absolut)
        }
        
        Util.runInBackground {
            NSFileManager.tmpDirectory().treatAsDirectoryPathAndIterate { filePath in
                if let fileName = filePath.lastPathComponent {
                    if fileName.hasSuffix(".mov") {
                        print("Deleting: ~/tmp/\(filePath.lastPathComponent!)")
                        let _ = try? fm.removeItemAtURL(filePath)
                    }
                }
            }
        }
        
        return relative
    }
    
    
}


