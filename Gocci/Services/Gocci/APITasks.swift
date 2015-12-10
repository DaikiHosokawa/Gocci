//
//  APITasks.swift
//  Gocci
//
//  Created by Markus Wanke on 30.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

class GocciVideoSharingTask: PersistentBaseTask {
    
    let timestamp: String
    let userID: String
    let restaurantID: String
    let cheerFlag: Bool
    let kakaku: String
    let categoryID: String
    let tagID: String // this is unused??
    let comment: String
    let videoFilePath: String // For next chain task
    
    init(timestamp: String, userID: String, restaurantID: String, cheerFlag: Bool, kakaku: String, categoryID: String, tagID: String, comment: String, videoFilePath: String)
    {
        self.timestamp = timestamp
        self.userID = userID
        self.restaurantID = restaurantID
        self.cheerFlag = cheerFlag
        self.kakaku = kakaku
        self.categoryID = categoryID
        self.tagID = tagID
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
        self.tagID = dict["tagID"] as? String ?? ""
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
        dict["tagID"] = tagID
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
                    task.tagID == tagID &&
                    task.comment == comment &&
                    task.videoFilePath == videoFilePath
        }
        return false
    }
    
    override func run(finished: State->()) {
        
        guard Util.fileExists(videoFilePath) else {
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            finished(.FAILED_NETWORK)
            return
        }
        
        //
        //[APIClient POST:movieFileForAPI rest_id:rest_id cheer_flag:cheertag value:valueKakaku
        //    category_id:category tag_id:@"" memo:comment handler:^(id result, NSUInteger code, NSError *error)
        

        
//        let url = NSURL.fileURLWithPath(mp4filename)
//        
//        
//        // TODO TRANSLATION
//        let sharer = TwitterSharing()
//        sharer.onSuccess = {
//            Toast.成功("Video sharing", "Video waas successfully posted on twitter.")
//            print("Twitter posting sucessful: Post ID: " + $0)
//            finished(.DONE)
//        }
//        sharer.onFailure = {
//            print("Twitter posting shippai: \($0)")
//            
//            switch($0) {
//            case .ERROR_VIDEO_FILE_IO:
//                finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
//                
//            case .ERROR_NETWORK:
//                //Toast.情報("Twitter video sharing", "Network appears to be unstable. Will retry later")
//                
//                finished(PersistentBaseTask.State.FAILED_NETWORK)
//                
//            case .ERROR_TWITTER_API:
//                // TODO more punishmend. set retry count or extend waiting time
//                finished(PersistentBaseTask.State.FAILED_RECOVERABLE)
//                
//            case .ERROR_TWEET_MESSAGE_OVER_140:
//                // TODO show the user a screen where he can rewrite the message.
//                // Use the OverlayWindow class for that because you do not have any view Controllers here
//                finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
//                
//            case .ERROR_AUTHENTICATION:
//                
//                OverlayWindow.show { (viewController, hideAgain) -> () in
//                    
//                    TwitterAuthentication.authenticate(currentViewController: viewController) { token in
//                        
//                        if token == nil {
//                            Toast.失敗("Twitter login failed.", "Video will not be posted on Twitter")
//                            finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
//                        }
//                        else {
//                            Toast.成功("Twitter login successful.", "Will retry to post video on twitter")
//                            finished(PersistentBaseTask.State.FAILED_RECOVERABLE)
//                        }
//                    }
//                }
//            }
//        }
//        sharer.tweetVideo(localVideoFileURL: url, message: tweetMessage)
    }
    
    override var description: String {
        return super.description + " Timestamp: \(timestamp), Comment: \(comment)"
    }
    
}
















