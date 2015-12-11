//
//  Debug.swift
//  Gocci
//
//  Created by Ma Wa on 11.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



@objc class Debug: NSObject {
    
    
    class func afterAppLaunch() {
        
        let fm = NSFileManager.defaultManager()
        
        let task = NSBundle.mainBundle().pathForResource("unfinished_upload_task", ofType: "plist")!
        
        let dest = Util.documentsDirectory() + "/unfinishedTasks.plist"
        
        let _ = try? fm.removeItemAtPath(dest)

        try! fm.copyItemAtPath(task, toPath: dest)
        
        
        var path = Util.documentsDirectory() + "/user_posted_videos"
        
        if !fm.fileExistsAtPath(path) {
            try! fm.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }
        
        let videoFile = NSBundle.mainBundle().pathForResource("twosec", ofType: "mp4")!
        
        let _ = try? fm.copyItemAtPath(videoFile, toPath: path + "/2015-12-11-10-04-26_949.mp4")


    }
    
}