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
        
        guard let iid = Persistent.identity_id else {
            and(.FAILED_IRRECOVERABLE)
            return
        }
            
        NetOp.loginWithIID(iid) { code, msg in
            switch code {
                case NetOpResult.NETOP_SUCCESS:
                    AWS2.connectToBackEndWithUserDefData().continueWithBlock{ task -> AnyObject! in
                        and(.FAILED_RECOVERABLE)
                        return nil
                    }
                case NetOpResult.NETOP_NETWORK_ERROR:
                    and(.FAILED_NETWORK)
                case NetOpResult.NETOP_IDENTIFY_ID_NOT_REGISTERD:
                    and(.FAILED_IRRECOVERABLE)
                default:
                    and(.FAILED_RECOVERABLE)
            }
        }
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
        
        let localFileURL = NSURL.fileURLWithPath(filePath)
        
        guard Util.fileExists(filePath) else {
            finished(.FAILED_IRRECOVERABLE)
            return
        }
        
        guard Network.state != .OFFLINE else {
            finished(.FAILED_NETWORK)
            return
        }

        
        let completionHandler: (AWSS3TransferUtilityUploadTask!, NSError?) -> () = { task, error in
            if let error = error {
                print("=============== ERROR: FROM THE COMPLETION HANDLER! : \(error)")
                self.performAWSReLogin(finished)
            }
            else {
                print("=============== SUCCESS, upload completed.")
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
        return super.description + " FilePath: \(filePath), S3-FileName: \(s3FileName)"
    }
    
}
















