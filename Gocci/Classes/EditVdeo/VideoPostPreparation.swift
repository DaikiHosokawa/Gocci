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
    
    class func initiateUploadTasks(timestamp: String, restaurantID: String, cheerFlag: Bool, kakaku: String, categoryID: String, comment: String, videoFilePath: String)
    {
    
        GocciVideoSharingTask(timestamp: timestamp, userID: Persistent.user_id!, restaurantID: restaurantID, cheerFlag: cheerFlag, kakaku: kakaku, categoryID: categoryID, comment: comment, videoFilePath: videoFilePath).schedule()
        
    }
    
    
    class func saveVideoInDocumentsAndCleanUpVideoFragments(newVideoFile: NSURL) -> String {
        
        var path = Util.documentsDirectory() + "/user_posted_videos"
        let fm = NSFileManager.defaultManager()
        
        if !fm.fileExistsAtPath(path) {
            try! fm.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        
        // TODO very ugly, fix this soon
        path += "/" + Util.getUserDefString("post_time")! + "_" + Persistent.user_id! + ".mov"
        
        try! fm.moveItemAtURL(newVideoFile, toURL: path.asURL())
        
        let tmpFiles = try? NSFileManager.defaultManager().subpathsOfDirectoryAtPath(NSTemporaryDirectory())
        
        for tmpFile in tmpFiles ?? [] {
            if tmpFile.hasSuffix(".mov") {
                print("Deleting tmp file: \(tmpFile)")
            }
        }
        
        return path
    }
    
}


