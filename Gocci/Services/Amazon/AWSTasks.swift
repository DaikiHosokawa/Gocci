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
        
        APIHighLevel.nonInteractiveLogin(
            onIIDNotAvailible:  { and(.FAILED_IRRECOVERABLE) },
            onNetworkFailure:   { and(.FAILED_NETWORK)       },
            onAPIFailure:       { and(.FAILED_IRRECOVERABLE) },
            onAWSFailure:       { and(.FAILED_RECOVERABLE)   },
            onSuccess:          { and(.FAILED_RECOVERABLE)   }) // <- YES that is corrent. In the next task iteration the task gets a new chance
        
    }
    
        
    func handleError(error: NSError, and: State->()){
        if Util.errorIsNetworkConfigurationError(error) {
            and(.FAILED_NETWORK)
        }
        else {
            performAWSReLogin(and)
        }
    }
    
    override func run(finished: State->()) {
        
        let localFileURL = Util.absolutify(filePath)
        
        guard NSFileManager.fileExistsAtURL(localFileURL) else {
            sep("ERROR: AWSS3VideoUploadTask")
            log("Video file does not exist")
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            sep("ERROR: AWSS3VideoUploadTask")
            log("Network offline, trying later")
            finished(.FAILED_NETWORK)
            return
        }

        
        let completionHandler: (AWSS3TransferUtilityUploadTask!, NSError?) -> () = { task, error in
            if let error = error {
                self.sep("ERROR: AWSS3VideoUploadTask")
                self.log("ERROR: FROM THE COMPLETION HANDLER! : \(error)")
                self.log("Performing AWS Relogin...")
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
                print("=============== ERROR: ", error)
                self.handleError(error, and: finished)
            }
            else if let exception = task.exception {
                print("=============== ERROR: ", exception)
                self.performAWSReLogin(finished)
            }
            
            return nil
        }
    }
    
    override var description: String {
        return super.description + " FilePath: \(NSFileManager.documentsDirectory() + filePath), S3-FileName: \(s3FileName)"
    }
    
}
















