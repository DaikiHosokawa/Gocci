//
//  TwitterTasks.swift
//  Gocci
//
//  Created by Markus Wanke on 30.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



class TwitterVideoSharingTask: PersistentBaseTask {
    let tweetMessage: String
    let mp4filename: String
    
    init(tweetMessage: String, mp4filename: String) {
        self.tweetMessage = tweetMessage
        self.mp4filename = mp4filename
        super.init(identifier: String(self.dynamicType))
    }
    
    override init?(dict: NSDictionary) {
        self.tweetMessage = dict["tweetMessage"] as? String ?? ""
        self.mp4filename = dict["mp4filename"] as? String ?? ""
        super.init(dict: dict)
        if tweetMessage == "" || mp4filename == "" { return nil }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["tweetMessage"] = tweetMessage
        dict["mp4filename"] = mp4filename
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? TwitterVideoSharingTask {
            return task.tweetMessage == tweetMessage && task.mp4filename == mp4filename
        }
        return false
    }
    
    override func run(finished: State->()) {
        
        let url = NSURL.fileURLWithPath(mp4filename)
        
        
        // TODO TRANSLATION
        let sharer = TwitterSharing()
        sharer.onSuccess = {
            Toast.成功("Video sharing", "Video waas successfully posted on twitter.")
            print("Twitter posting sucessful: Post ID: " + $0)
            finished(.DONE)
        }
        sharer.onFailure = {
            print("Twitter posting shippai: \($0)")
            
            switch($0) {
            case .ERROR_VIDEO_FILE_IO:
                finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
                
            case .ERROR_NETWORK:
                //Toast.情報("Twitter video sharing", "Network appears to be unstable. Will retry later")
                
                finished(PersistentBaseTask.State.FAILED_NETWORK)
                
            case .ERROR_TWITTER_API:
                // TODO more punishmend. set retry count or extend waiting time
                finished(PersistentBaseTask.State.FAILED_RECOVERABLE)
                
            case .ERROR_TWEET_MESSAGE_OVER_140:
                // TODO show the user a screen where he can rewrite the message. 
                // Use the OverlayWindow class for that because you do not have any view Controllers here
                finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
                
            case .ERROR_AUTHENTICATION:
                
                OverlayWindow.show { (viewController, hideAgain) -> () in
                    
                    let eh = {
                        Toast.失敗("Twitter login failed.", "Video will not be posted on Twitter")
                        finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
                    }
                    
                    TwitterAuthentication.authenticate(currentViewController: viewController, errorHandler: eh) { token in
                        Toast.成功("Twitter login successful.", "Will retry to post video on twitter")
                        finished(PersistentBaseTask.State.FAILED_RECOVERABLE)
                    }
                }
            }
        }
        sharer.tweetVideo(localVideoFileURL: url, message: tweetMessage)
    }
    
    override var description: String {
        return super.description + " TweetMessage: \(tweetMessage), MP4File: \(mp4filename)"
    }
    
}
















