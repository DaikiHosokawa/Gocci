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
        
        var category_id: String = ""
        var category_string: String = "" { didSet { notifyNewCategory?(category_string) } }
        var value: String = ""           { didSet { notifyNewPrice?(value) } }
        var tag_id: String = ""
        var memo: String = ""
        var cheer_flag: Bool = false  
        
        var prepared_restaurant: Bool = true
        var rest_name: String = "" { didSet { notifyNewRestName?(rest_name) } }
        var lat: Double = 0.0
        var lon: Double = 0.0
        
        
        var notifyNewPrice: (String->())? = nil
        var notifyNewCategory: (String->())? = nil
        var notifyNewRestName: (String->())? = nil
        
    }
    
    @objc static var postData = PostData()
    
    class func resetPostData() {
        postData = PostData()
    }
    
    
    
    class func initiateUploadTaskChain(videoFileInTMPFolder: NSURL) {
        
        let timestamp = Util.timestampUTC()
        
        let videoFilePath = saveVideoInDocumentsAndCleanUpVideoFragments(videoFileInTMPFolder, timestamp: timestamp)
        
        
        print("========================================================")
        print("STARTING THE VIDEO UPLAOD TASK CHAIN")
        print("TYPE: " + (postData.prepared_restaurant ? "With new Retaurant" : "With retaurant from GPS list" ))
        print("========================================================")
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
                videoFilePath: videoFilePath).schedule()
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
                videoFilePath: videoFilePath).schedule()
        }
        
        
        
        resetPostData()
    }
    
    
    

    
//    class func initiateUploadTasks(timestamp: String, restaurantID: String, cheerFlag: Bool, categoryID: String, comment: String, videoFilePath: String)
//    {
//        GocciVideoSharingTask(timestamp: timestamp,
//            userID: Persistent.user_id!,
//            restaurantID: restaurantID,
//            cheerFlag: cheerFlag,
//            kakaku: postData.value,
//            categoryID: categoryID,
//            comment: comment,
//            videoFilePath: videoFilePath).schedule()
//        
//        resetPostData()
//    }
    
    
    class func saveVideoInDocumentsAndCleanUpVideoFragments(newVideoFile: NSURL, timestamp: String) -> String {
        
        var path = Util.documentsDirectory() + "/user_posted_videos"
        let fm = NSFileManager.defaultManager()
        
        if !fm.fileExistsAtPath(path) {
            try! fm.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        
        // TODO very ugly, fix this soon
        path += "/" + timestamp + "_" + Persistent.user_id! + ".mp4"
        
        try! fm.moveItemAtURL(newVideoFile, toURL: path.asURL())
        
        let tmpFiles = try? NSFileManager.defaultManager().subpathsOfDirectoryAtPath(NSTemporaryDirectory())
        
        for tmpFile in tmpFiles ?? [] {
            if tmpFile.hasSuffix(".mov") {
                print("Deleting tmp file: \(tmpFile)")
            }
        }
        
        return path
    }
    
    
//    class func restaurantPopup(vc: UIViewController) {
//        if Network.state == .OFFLINE {
//            
//        }
//        else {
//            
//            
//            [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[RestPopupViewController new]];
//            
//        }
//        
//    }
}


