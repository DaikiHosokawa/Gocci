//
//  FacebookTasks.swift
//  Gocci
//
//  Created by Markus Wanke on 13.01.16.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class FacebookVideoSharingTask: PersistentBaseTask {
    let timelineMessage: String
    let relativeFilePath: String
    
    init(timelineMessage: String, relativeFilePath: String) {
        self.timelineMessage = timelineMessage
        self.relativeFilePath = relativeFilePath
        super.init(identifier: String(self.dynamicType))
    }
    
    override init?(dict: NSDictionary) {
        
        self.timelineMessage = dict["timelineMessage"] as? String ?? "__PLACEHOLDER_4283492084092__"
        self.relativeFilePath = dict["relativeFilePath"] as? String ?? ""
        super.init(dict: dict)
        if timelineMessage == "__PLACEHOLDER_4283492084092__" || relativeFilePath == "" { return nil }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["timelineMessage"] = timelineMessage
        dict["relativeFilePath"] = relativeFilePath
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? FacebookVideoSharingTask {
            return task.timelineMessage == timelineMessage && task.relativeFilePath == relativeFilePath
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
            sep("ERROR: FacebookVideoSharingTask")
            log("File \(Util.absolutify(relativeFilePath)) hardlink could not be deleted. This should never happen. Investigate...")
        }
    }
    
    override func run(finished: State->()) {
        
        sep("PERFORM: FacebookVideoSharingTask")
        log("timelineMessage = \(timelineMessage)")
        log("relativeFilePath = \(relativeFilePath)")
        
        let fullFilePathURL = Util.absolutify(relativeFilePath)
        
        guard NSFileManager.fileExistsAtURL(fullFilePathURL) else {
            err("File \(fullFilePathURL) does not exist")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        
        let sharer = FacebookSharing()
        sharer.onSuccess = {
            //Toast.成功("Video sharing", "Video was successfully posted on Facebook.")
            self.sep("SUCCESS: FacebookVideoSharingTask")
            self.log("Facebook posting sucessful: Post ID: \($0)")
            finished(.DONE)
        }
        sharer.onFailure = {
            self.err("Facebook posting failed because of \($0)")
            
            switch($0) {
            case .ERROR_VIDEO_FILE_IO:
                finished(PersistentBaseTask.State.FAILED_IRRECOVERABLE)
                
            case .ERROR_NETWORK:
                //Toast.情報("Facebook video sharing", "Network appears to be unstable. Will retry later")
                finished(PersistentBaseTask.State.FAILED_NETWORK)
                
            case .ERROR_FACEBOOK_API:
                // TODO more punishmend. set retry count or extend waiting time
                finished(PersistentBaseTask.State.FAILED_RECOVERABLE)
                
            case .ERROR_AUTHENTICATION:
                
                OverlayWindow.oneTimeViewController { viewController in
                    
                    FacebookAuthentication.authenticateWithPublishRights(currentViewController: viewController) { token in
                        finished( token == nil ? .FAILED_IRRECOVERABLE : .FAILED_RECOVERABLE)
                    }
                }
            }
        }
        sharer.shareVideoOnFacebook(fullFilePathURL, description: timelineMessage, thumbnail: nil)
    }
    
    override var description: String {
        return super.description + " timelineMessage: \(timelineMessage), MP4File: \(relativeFilePath)"
    }
    
}

































