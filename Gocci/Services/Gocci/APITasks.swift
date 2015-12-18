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
        

        
        guard Util.fileExists(Util.documentsDirectory() + videoFilePath) else {
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            finished(.FAILED_NETWORK)
            return
        }
        
        APIClient.restInsert(restName, latitude: lat, longitude: lon) {
            
            (result, code, error) -> Void in

            
            if let error = error {
                if Util.errorIsNetworkConfigurationError(error) {
                    finished(.FAILED_NETWORK)
                }
                else {
                    finished(.FAILED_RECOVERABLE)
                }
            }
            
            if code >= 200 && code < 300 {
                if let result = result as? [String: AnyObject] {
                    if let rescode = result["code"] as? Int {
                        if rescode == 200 {
                            
                            self.resultRetaurantID = result["rest_id"] as? String
                            finished(.DONE)
                            return
                        }
                    }
                }
            }
            
            
            finished(.FAILED_RECOVERABLE)
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
    
    init(timestamp: String, userID: String, restaurantID: String, cheerFlag: Bool, kakaku: String, categoryID: String, comment: String, videoFilePath: String)
    {
        self.timestamp = timestamp
        self.userID = userID
        self.restaurantID = restaurantID
        self.cheerFlag = cheerFlag
        self.kakaku = kakaku
        self.categoryID = categoryID
        //self.tagID = tagID
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
        //self.tagID = dict["tagID"] as? String ?? ""
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
        //dict["tagID"] = tagID
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
                //task.tagID == tagID &&
                task.comment == comment &&
                task.videoFilePath == videoFilePath
        }
        return false
    }
    
    override func legacy() -> PersistentBaseTask? {
        return AWSS3VideoUploadTask(filePath: videoFilePath, s3FileName: timestamp + "_" + userID + ".mp4")
    }
    
    override func run(finished: State->()) {
        
        guard Util.fileExists(Util.documentsDirectory() + videoFilePath) else {
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            finished(.FAILED_NETWORK)
            return
        }
        
        APIClient.POST(timestamp + "_" + userID, rest_id: restaurantID, cheer_flag: cheerFlag ? "1" : "0", value: kakaku, category_id: categoryID, tag_id: "1", memo: comment)
            {
                (result, code, error) -> Void in

                if let error = error {
                    if Util.errorIsNetworkConfigurationError(error) {
                        finished(.FAILED_NETWORK)
                    }
                    else {
                        finished(.FAILED_RECOVERABLE)
                    }
                }
                
                
                if code >= 200 && code < 300 {
                    if let result = result as? [String: AnyObject] {
                        if let rescode = result["code"] as? Int {
                            if rescode == 200 {
                                finished(.DONE)
                                return
                            }
                        }
                    }
                }
                
                finished(.FAILED_RECOVERABLE)
        }
        
    }
    
    override var description: String {
        return super.description + " Timestamp: \(timestamp), Comment: \(comment)"
    }
    
}
















