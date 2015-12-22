//
//  APITasks.swift
//  Gocci
//
//  Created by Markus Wanke on 30.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit








class RegisterForPushMessagesTask: PersistentBaseTask {
    
    let deviceToken: String
    
    init(deviceToken: String) {
        self.deviceToken = deviceToken
        super.init(identifier: String(self.dynamicType) + " " + deviceToken)
    }
    
    override init?(dict: NSDictionary) {
        self.deviceToken = dict["deviceToken"] as? String ?? ""
        super.init(dict: dict)
        if deviceToken == "" { return nil }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["deviceToken"] = deviceToken
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        // there should never be two tasks, so this one will be replaced at any cost
        return task is RegisterForPushMessagesTask
    }
    
    override func run(finished: State->()) {
        
        guard Persistent.identity_id != nil else {
            super.log("TASK ERROR: can't register an devie token without an account (identify_id)")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        let req = API3.set.device()
        
        req.parameters.device_token = deviceToken
        req.parameters.model = UIDevice.currentDevice().model
        req.parameters.os = "iOS"
        req.parameters.ver = Util.operationSystemVersion()
        
        req.onNetworkTrouble { err, _ in
            if err == .ERROR_RE_AUTH_FAILED {
                finished(.FAILED_IRRECOVERABLE)
            }
            finished(.FAILED_NETWORK)
        }
        
        req.onAnyAPIError {
            finished(.FAILED_IRRECOVERABLE)
        }
        
        req.perform {
            Persistent.registerd_device_token = self.deviceToken;
            finished(.DONE)
        }
        
    }
    
    override var description: String {
        return "Register device token task with: \(deviceToken)"
    }
    
}






class GocciAddRestaurantTask: PersistentBaseTask {
    
    let restName: String
    let lat: Double
    let lon: Double
    
    let timestamp: String
    let userID: String
    let cheerFlag: Bool
    let kakaku: String
    let categoryID: String
    //let tagID: String // this is unused??
    let comment: String
    let videoFilePath: String // For next chain task
    
    var resultRetaurantID: String? = nil
    
    init(restName: String, lat: Double, lon: Double, timestamp: String, userID: String, cheerFlag: Bool, kakaku: String, categoryID: String, comment: String, videoFilePath: String)
    {
        self.restName = restName
        self.lat = lat
        self.lon = lon
        
        self.timestamp = timestamp
        self.userID = userID
        self.cheerFlag = cheerFlag
        self.kakaku = kakaku
        self.categoryID = categoryID
        //self.tagID = tagID
        self.comment = comment
        self.videoFilePath = videoFilePath // For next chain task
        super.init(identifier: String(self.dynamicType))
    }
    
    override init?(dict: NSDictionary) {
        
        // TODO make this not ugly
        let ph = "__PLACE_HOLDER__738457395398539875398__"
        
        self.restName = dict["restName"] as? String ?? ""
        self.lat = dict["lat"] as? Double ?? 0.0    // TODO change this to sane defaults
        self.lon = dict["lon"] as? Double ?? 0.0
        
        
        self.timestamp = dict["timestamp"] as? String ?? ""
        self.userID = dict["userID"] as? String ?? ""
        self.cheerFlag = dict["cheerFlag"] as? Bool ?? false
        self.kakaku = dict["kakaku"] as? String ?? ph
        self.categoryID = dict["categoryID"] as? String ?? ""
        //self.tagID = dict["tagID"] as? String ?? ""
        self.comment = dict["comment"] as? String ?? ph
        self.videoFilePath = dict["videoFilePath"] as? String ?? ""
        
        super.init(dict: dict)
        if restName == "" || timestamp == "" || userID == "" || kakaku == ph || categoryID == "" || comment == ph || videoFilePath == "" {
            return nil
        }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["restName"] = restName
        dict["lat"] = lat
        dict["lon"] = lon
        
        dict["timestamp"] = timestamp
        dict["userID"] = userID
        dict["cheerFlag"] = cheerFlag
        dict["kakaku"] = kakaku
        dict["categoryID"] = categoryID
        dict["comment"] = comment
        dict["videoFilePath"] = videoFilePath
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? GocciAddRestaurantTask {
            return  task.timestamp == timestamp &&
                task.restName == restName &&
//                task.lat == lat &&  // TODO change this to sane float comparsion
//                task.lon == lon &&
                task.userID == userID &&
                task.cheerFlag == cheerFlag &&
                task.kakaku == kakaku &&
                task.categoryID == categoryID &&
                task.comment == comment &&
                task.videoFilePath == videoFilePath
        }
        return false
    }
    
    override func legacy() -> PersistentBaseTask? {
        
        if resultRetaurantID == nil {
            return nil
        }
        
        return GocciVideoSharingTask(timestamp: timestamp, userID: userID, restaurantID: resultRetaurantID!, cheerFlag: cheerFlag, kakaku: kakaku, categoryID: categoryID, comment: comment, videoFilePath: videoFilePath)
    }
    
    override func run(finished: State->()) {
        
        guard Network.state != .OFFLINE else {
            finished(.FAILED_NETWORK)
            return
        }
        
        let req = API3.set.rest()
        
        req.parameters.restname = restName
        req.parameters.lat = "\(lat)"
        req.parameters.lon = "\(lon)"
        
        
        req.onNetworkTrouble {
            self.sep("WARN: GocciAddRestaurantTask")
            self.log("NetworkTrouble: \($0): \($1)")
            finished(.FAILED_NETWORK)
        }
        
        req.onAnyAPIError {
            self.sep("ERROR: GocciAddRestaurantTask")
            self.log("API error. Giving up :(")
            finished(.FAILED_IRRECOVERABLE)
        }
        
        req.perform { payload in
            self.sep("SUCCESS: GocciAddRestaurantTask")
            self.log("New Rest ID: \(payload.rest_id)")
            
            self.resultRetaurantID = payload.rest_id
            finished(.DONE)
        }

    }
    
    override var description: String {
        return super.description + " Timestamp: \(timestamp), RestName: \(restName)"
    }
    
}


class GocciVideoSharingTask: PersistentBaseTask {
    
    let timestamp: String
    let userID: String
    let restaurantID: String
    let cheerFlag: Bool
    let kakaku: String
    let categoryID: String
    //let tagID: String // this is unused??
    let comment: String
    let videoFilePath: String // For next chain task
    
    var finalFileNamePath: String? = nil
    
    init(timestamp: String, userID: String, restaurantID: String, cheerFlag: Bool, kakaku: String, categoryID: String, comment: String, videoFilePath: String)
    {
        self.timestamp = timestamp
        self.userID = userID
        self.restaurantID = restaurantID
        self.cheerFlag = cheerFlag
        self.kakaku = kakaku
        self.categoryID = categoryID
        self.comment = comment
        self.videoFilePath = videoFilePath // For next chain task
        super.init(identifier: String(self.dynamicType))
    }
    
    override init?(dict: NSDictionary) {
        self.timestamp = dict["timestamp"] as? String ?? ""
        self.userID = dict["userID"] as? String ?? ""
        self.restaurantID = dict["restaurantID"] as? String ?? ""
        self.cheerFlag = dict["cheerFlag"] as? Bool ?? false
        self.kakaku = dict["kakaku"] as? String ?? ""
        self.categoryID = dict["categoryID"] as? String ?? ""
        self.comment = dict["comment"] as? String ?? ""
        self.videoFilePath = dict["videoFilePath"] as? String ?? ""
        
        super.init(dict: dict)
        if timestamp == "" || userID == "" || restaurantID == "" || kakaku == "" || categoryID == "" || comment == "" || videoFilePath == "" {
            return nil
        }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["timestamp"] = timestamp
        dict["userID"] = userID
        dict["restaurantID"] = restaurantID
        dict["cheerFlag"] = cheerFlag
        dict["kakaku"] = kakaku
        dict["categoryID"] = categoryID
        dict["comment"] = comment
        dict["videoFilePath"] = videoFilePath
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? GocciVideoSharingTask {
            return  task.timestamp == timestamp &&
                task.userID == userID &&
                task.restaurantID == restaurantID &&
                task.cheerFlag == cheerFlag &&
                task.kakaku == kakaku &&
                task.categoryID == categoryID &&
                task.comment == comment &&
                task.videoFilePath == videoFilePath
        }
        return false
    }
    
    override func legacy() -> PersistentBaseTask? {
        if let ffn = finalFileNamePath {
            return AWSS3VideoUploadTask(filePath: ffn, s3FileName: timestamp + "_" + userID + ".mp4")
        }
        sep("ERROR: GocciVideoSharingTask")
        log("Lagacy is NIL even though the task ended in .DONE status. WTF?")
        return nil
    }
    
    override func run(finished: State->()) {
        
        
        
        guard NSFileManager.fileExistsAtURL(Util.absolutify(videoFilePath)) else {
            sep("ERROR: GocciVideoSharingTask")
            log("Video file does not exist")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            sep("WARN: GocciVideoSharingTask")
            log("Can't upload video, no network availible")
            finished(.FAILED_NETWORK)
            return
        }
        
        let req = API3.set.post()
        
        req.parameters.rest_id = restaurantID
        req.parameters.movie_name = timestamp + "_" + userID
        req.parameters.cheer_flag = cheerFlag ? "1" : "0"
        
        if categoryID != "" && categoryID != "0" && categoryID != "1" {
            req.parameters.category_id = categoryID
        }
        
        if kakaku != "" && kakaku != "0" {
            req.parameters.value = kakaku
        }
        
        if comment != "" {
            req.parameters.memo = comment
        }
        
        req.onNetworkTrouble {
            self.sep("WARN: GocciVideoSharingTask")
            self.log("NetworkTrouble: \($0): \($1)")
            finished(.FAILED_NETWORK)
        }
        
        req.onAnyAPIError {
            self.sep("ERROR: GocciVideoSharingTask")
            self.log("API error. Giving up :(")
            finished(.FAILED_IRRECOVERABLE)
        }
        
        sep("PERFORM: GocciVideoSharingTask")
        log("timestamp = \(timestamp)")
        log("userID = \(userID)")
        log("restaurantID = \(restaurantID)")
        log("cheerFlag = \(cheerFlag)")
        log("value = \(kakaku)")
        log("categoryID = \(categoryID)")
        log("comment = \(comment)")
        log("videoFilePath = \(videoFilePath)")
        
        req.perform { payload in
            // rename the file to post id
            
            let fm = NSFileManager.defaultManager()
            
            let source = Util.absolutify(self.videoFilePath)
            let target = NSFileManager.postedVideosDirectory().URLByAppendingPathComponent("\(payload.post_id).mp4")
            
            if NSFileManager.fileExistsAtURL(target) {
                self.sep("STRANGE: GocciVideoSharingTask")
                self.log("File with post_id \(payload.post_id).mp4 already exists. That should never happen. We override...")
                
                do {
                    try fm.removeItemAtURL(target)
                } catch let error as NSError {
                    self.sep("VERY STRANGE: GocciVideoSharingTask")
                    self.log("File with post_id \(payload.post_id).mp4 already exists. And can't be deleted. Giving up. ERROR: \(error)")
                    finished(.FAILED_IRRECOVERABLE)
                    return
                }
            }
            
            do {
                try fm.moveItemAtURL(source, toURL: target)
            } catch let error as NSError {
                self.sep("VERY STRANGE: GocciVideoSharingTask")
                self.log("File \(source) could not be renamed to \(target). Giving up. ERROR: \(error)")
                finished(.FAILED_IRRECOVERABLE)
                return
            }
            
            self.sep("PERFORM: GocciVideoSharingTask")
            self.log("Finished Succesfully. Post ID: \(payload.post_id)")
            self.log("Video file saved at \(target)")
            self.finalFileNamePath = POSTED_VIDEOS_DIRECTORY + "/\(payload.post_id).mp4"
            finished(.DONE)
        }
        

        
    }
    
    override var description: String {
        return super.description + " Timestamp: \(timestamp), Comment: \(comment)"
    }
    
}
















