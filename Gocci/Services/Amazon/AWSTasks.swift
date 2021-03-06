//
//  AWSTasks.swift
//  Gocci
//
//  Created by Markus Wanke on 08.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

class AWSS3VideoUploadTask: PersistentBaseTask {
    let filePath: String
    let s3FileName: String
    
    init(filePath: String, s3FileName: String) {
        self.filePath = filePath
        self.s3FileName = s3FileName
        super.init(identifier: String(self.dynamicType))
    }
    
    override init?(dict: NSDictionary) {
        self.filePath = dict["filePath"] as? String ?? ""
        self.s3FileName = dict["s3FileName"] as? String ?? ""
        super.init(dict: dict)
        if filePath == "" || s3FileName == "" { return nil }
    }
    
    override func dictonaryRepresentation() -> NSMutableDictionary {
        let dict = super.dictonaryRepresentation()
        dict["filePath"] = filePath
        dict["s3FileName"] = s3FileName
        return dict
    }
    
    override func equals(task: PersistentBaseTask) -> Bool {
        if let task = task as? AWSS3VideoUploadTask {
            return task.filePath == filePath && task.s3FileName == s3FileName
        }
        return false
    }
    
    
    func performAWSReLogin(and: State->()) {
        self.log("Performing AWS Relogin...")
        APIHighLevel.nonInteractiveLogin(
            onIIDNotAvailible:  { and(.FAILED_IRRECOVERABLE) },
            onNetworkFailure:   { and(.FAILED_NETWORK)       },
            onAPIFailure:       { and(.FAILED_IRRECOVERABLE) },
            onAWSFailure:       { and(.FAILED_RECOVERABLE)   },
            onSuccess:          { and(.FAILED_RECOVERABLE)   }) // <- YES that is corrent. In the next task iteration the task gets a new chance
    }
    
        
    func handleError(error: NSError, and: State->()){
        if Util.errorIsNetworkConfigurationError(error) {
            sep("WARN: AWSS3VideoUploadTask")
            log("Network offline, trying later")
            and(.FAILED_NETWORK)
        }
        else {
            performAWSReLogin(and)
        }
    }
    
    override func run(finished: State->()) {
        
        let localFileURL = Util.absolutify(filePath)
        
        guard NSFileManager.fileExistsAtURL(localFileURL) else {
            err("Video file does not exist")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            sep("WARN: AWSS3VideoUploadTask")
            log("Network offline, trying later")
            finished(.FAILED_NETWORK)
            return
        }

        
        let completionHandler: (AWSS3TransferUtilityUploadTask!, NSError?) -> () = { task, error in
            if let error = error {
                self.err("FROM THE AWS COMPLETION HANDLER! : \(error)")
                self.performAWSReLogin(finished)
            }
            else {
                self.sep("SUCCESS: AWSS3VideoUploadTask")
                self.log("Upload completed!")
                finished(.DONE)
            }
        }
        
        
        
        let tu = AWS2.getS3uploader()
        
        let uploadTask = tu.uploadFile(localFileURL,
            bucket: AWS_S3_VIDEO_UPLOAD_BUCKET,
            key: s3FileName,
            contentType: "video/quicktime",
            expression: nil,
            completionHander: completionHandler)
        
        uploadTask.continueWithBlock{ task in
            if let error = task.error {
                self.handleError(error, and: finished)
            }
            else if let exception = task.exception {
                self.performAWSReLogin(finished)
            }
            
            return nil
        }
    }
    
    override var description: String {
        return super.description + " FilePath: \(NSFileManager.documentsDirectory().path ?? "" + filePath), S3-FileName: \(s3FileName)"
    }
    
}








class AWSS3ProfileImageUploadTask: AWSS3VideoUploadTask {
    
    // unique task. new one kills older ones
    override func equals(task: PersistentBaseTask) -> Bool {
        return task is AWSS3ProfileImageUploadTask
    }
    
    override func handleError(error: NSError, and: State->()){
        if Util.errorIsNetworkConfigurationError(error) {
            sep("WARN: AWSS3ProfileImageUploadTask")
            log("Network offline, trying later")
            and(.FAILED_NETWORK)
        }
        else {
            performAWSReLogin(and)
        }
    }
    
    override func run(finished: State->()) {
        
        let localFileURL = Util.absolutify(filePath)
        
        guard NSFileManager.fileExistsAtURL(localFileURL) else {
            err("Video file does not exist")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            sep("WARN: AWSS3ProfileImageUploadTask")
            log("Network offline, trying later")
            finished(.FAILED_NETWORK)
            return
        }
        
        
        let completionHandler: (AWSS3TransferUtilityUploadTask!, NSError?) -> () = { task, error in
            if let error = error {
                self.err("FROM THE AWS COMPLETION HANDLER! : \(error)")
                self.performAWSReLogin(finished)
            }
            else {
                self.sep("SUCCESS: AWSS3ProfileImageUploadTask")
                self.log("Upload completed!")
                
                Toast.情報("SUCCESS", "New profile image upload complete") // TODO TRANSLATION
                finished(.DONE)
            }
        }
        
        
        
        let tu = AWS2.getS3uploader()
        
        let uploadTask = tu.uploadFile(localFileURL,
            bucket: AWS_S3_PROFILE_IMAGE_UPLOAD_BUCKET,
            key: s3FileName,
            contentType: "image/png",
            expression: nil,
            completionHander: completionHandler)
        
        uploadTask.continueWithBlock{ task in
            if let error = task.error {
                self.handleError(error, and: finished)
            }
            else if let exception = task.exception {
                self.performAWSReLogin(finished)
            }
            
            return nil
        }
    }
    
    
}














