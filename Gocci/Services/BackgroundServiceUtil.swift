//
//  BackgroundServiceUtil.swift
//  Gocci
//
//  Created by Markus Wanke on 29.01.16.
//  Copyright © 2016 Massara. All rights reserved.
//

import Foundation


class BackgroundServiceUtil {
    
    class func performBackgroundUploadRequest(
        request: NSURLRequest,
        onSuccess: ((statusCode: Int, data: NSData)->())?,
        onFailure: ((errorMessage: String)->())? )
    {
        BackgroundUploadTaskDelegate(onSuccess: onSuccess!, onFailure: onFailure!).perform(request)
    }
    
    class BackgroundUploadTaskDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
        
        var session: NSURLSession! = nil
        
        let onSuccess: (statusCode: Int, data: NSData)->()
        let onFailure: (errorMessage: String)->()
        
        let identifier = "SNS_BG_UploadThread_" + Util.randomAlphaNumericStringWithLength(12)
        let tmpurl = NSFileManager.tmpDirectory().URLByAppendingPathComponent("SNS_BG_Upload_" + Util.randomAlphaNumericStringWithLength(20) + ".mp4")
        
        var data: NSMutableData = NSMutableData() // the data recieved from the server will be stored here
        

        init(onSuccess: (statusCode: Int, data: NSData)->(), onFailure: (errorMessage: String)->()) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
//            Lo.purple("NSURL SESSION DELEGATE WAS CREATED.")
        }
        
        func perform(request: NSURLRequest) {
            
            guard request.HTTPMethod == "POST" else {
                onFailure(errorMessage: "BackgroundUploadTaskDelegate only supports HTTP POST requests")
                return
            }
            
            guard let data = request.HTTPBody else {
                onFailure(errorMessage: "Request hast no HTTP body, so nothinf to send.")
                return
            }
            
            guard data.writeToURL(tmpurl, atomically: true) && NSFileManager.fileExistsAtURL(tmpurl) else {
                onFailure(errorMessage: "Could not write tmp uploadfile to tmp directory.")
                return
            }
            
            let config  = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(self.identifier)
            config.sessionSendsLaunchEvents = true
            session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
            // delegate now in strong reference cycle with the session. call [invalidateAndCancel] on the session to free it
            session.uploadTaskWithRequest(request, fromFile: tmpurl).resume()
        }
        
//        deinit {
//            Lo.purple("AN not so IMMORTAL DIED.")
//        }
        
        
        
        func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
            Lo.purple("Gocci rised from the dead!")
        }
        
        
        func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            self.data.appendData(data)
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
            
//            Lo.green(data.asUTF8String())
            
            defer {
                self.session.invalidateAndCancel()
            }
            
            if !NSFileManager.rm(tmpurl) {
                Lo.error("Could not delete background uploads tmp file")
            }
            
            guard error == nil else {
                onFailure(errorMessage: error?.localizedDescription ?? "No error message")
                return
            }
            
            guard let resp = task.response as? NSHTTPURLResponse else {
                onFailure(errorMessage: "Response is not an HTTP Response")
                return
            }
            
            onSuccess(statusCode: resp.statusCode, data: data)
        }
        
        
//        func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//            let ratio: Double = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
//            print("SNS Upload completition (maybe only one chunc):  \(Int(ratio * 100))% ::   \(totalBytesSent) / \(totalBytesExpectedToSend)")
//        }
        
//        func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
//            Lo.green("Session became in validated. \(error ?? "No error!")")
//        }
    }
}





