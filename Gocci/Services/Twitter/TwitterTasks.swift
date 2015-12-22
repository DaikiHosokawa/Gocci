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
    let relativeFilePath: String // relative to Library path
    
    init(tweetMessage: String, relativeFilePath: String) {
        self.tweetMessage = tweetMessage
        self.relativeFilePath = relativeFilePath
        super.init(identifier: String(self.dynamicType))
    }
    
    override init?(dict: NSDictionary) {
        self.tweetMessage = dict["tweetMessage"] as? String ?? ""
        self.relativeFilePath = dict["relativeFilePath"] as? String ?? ""
        super.init(dict: dict)
        if tweetMessage == "" || relativeFilePath == "" { return nil }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["tweetMessage"] = tweetMessage
        dict["relativeFilePath"] = relativeFilePath
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? TwitterVideoSharingTask {
            return task.tweetMessage == tweetMessage && task.relativeFilePath == relativeFilePath
        }
        return false
    }
    
    override func teardown() {
        // hard link not needed anymore
        let fm = NSFileManager.defaultManager()
        do {
            try fm.removeItemAtURL(Util.absolutify(relativeFilePath))
        }
        catch {
            sep("ERROR: TwitterVideoSharingTask")
            log("File \(Util.absolutify(relativeFilePath)) hardlink could not be deleted. This should never happen. Investigate...")
        }
    }
    
    override func run(finished: State->()) {
        
        sep("PERFORM: TwitterVideoSharingTask")
        log("tweetMessage = \(tweetMessage)")
        log("relativeFilePath = \(relativeFilePath)")
        
        let fullFilePathURL = Util.absolutify(relativeFilePath)
        
        guard NSFileManager.fileExistsAtURL(fullFilePathURL) else {
            sep("ERROR: TwitterVideoSharingTask")
            log("File \(fullFilePathURL) does not exist")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        
        // TODO TRANSLATION
        let sharer = TwitterSharing()
        sharer.onSuccess = {
            //Toast.成功("Video sharing", "Video was successfully posted on twitter.")
            self.sep("SUCCESS: TwitterVideoSharingTask")
            self.log("Twitter posting sucessful: Post ID: \($0)")
            finished(.DONE)
        }
        sharer.onFailure = {
            self.sep("FAILURE: TwitterVideoSharingTask")
            self.log("Twitter posting failed because of \($0)")
            
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
                    
                    TwitterAuthentication.authenticate(currentViewController: viewController) { token in
                        hideAgain() // TODO TEST THIS
                        if token == nil {
                            finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
                        }
                        else {
                            finished(PersistentBaseTask.State.FAILED_RECOVERABLE)
                        }
                    }
                }
            }
        }
        sharer.tweetVideo(localVideoFileURL: fullFilePathURL, message: tweetMessage)
    }
    
    override var description: String {
        return super.description + " TweetMessage: \(tweetMessage), MP4File: \(relativeFilePath)"
    }
    
}
















