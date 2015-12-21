//
//  ReAuthFilterHack.swift
//  Gocci
//
//  Created by Ma Wa on 02.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

@objc class ReAuthFilterHack: NSObject {
    
    let manager: AFHTTPSessionManager
    
    init(withBaseURL: NSURL) {
        
        
        let cnfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        manager = AFHTTPSessionManager(baseURL: withBaseURL, sessionConfiguration: cnfig)
        
        manager.requestSerializer = AFJSONRequestSerializer()
     
        manager.responseSerializer.acceptableContentTypes = Set(["application/json", "text/html", "text/javascript"])
    }
    
    
    
    func relogin(uri: String, parameters: NSDictionary,
        success: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->(),
        failure: (task: NSURLSessionDataTask!, error: NSError?)->())
    {
        Lo.yellow("APIv2 detected: 401: UNATHENTICATED!! performing relogin... ")
        
        
        
        let onSucc: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->() = { task, responseObject in
            Lo.yellow(responseObject)
            
            
            if let json = responseObject as? [String: String] {
                if json["code"] == "401" {
                    Lo.error("=======================================================================")
                    Lo.error("APIv2 not usable after successful APIv3 login. Giving up")
                    return
                }
            }
            
            success(task: task, responseObject: responseObject)
        }
        
        let onFail: (task: NSURLSessionDataTask!, error: NSError?)->() = { task, error in
            // failure will be passed through
            failure(task: task, error: error)
        }
        
        
        APIHighLevel.simpleLogin { succ in
            if succ {
                Lo.yellow("GET called for: \(uri) AFTER re AUTH!! ")
                Lo.yellow("Using session ID: \(APILowLevel.fuelmid_session_cookie)")
                self.manager.requestSerializer.setValue(APILowLevel.USER_AGENT, forHTTPHeaderField: "User-Agent")
                self.manager.requestSerializer.setValue("fuelmid=\(APILowLevel.fuelmid_session_cookie)", forHTTPHeaderField: "Cookie")
                
                guard APILowLevel.fuelmid_session_cookie != nil && APILowLevel.fuelmid_session_cookie != "" else {
                    Lo.error("=======================================================================")
                    Lo.error("No session cookie after relogin giving up")
                    return
                }
                
                //self.manager.GET(uri, parameters: parameters, success: success, failure: failure)
                self.manager.GET(uri, parameters: parameters, success: onSucc, failure: onFail)
                
            }
            else {
                Lo.error("=======================================================================")
                Lo.error("Authentitication on relogin failed. should never happen")
            }
            // if it is not castable we stop here. because it would crash in APIClient after that
        }
    }
    
    
    
    func GET(uri: String, parameters: NSDictionary,
        success: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->(),
        failure: (task: NSURLSessionDataTask!, error: NSError?)->())
    {
        Lo.yellow("GET called for: \(uri)")
        Lo.yellow("Using session ID: \(APILowLevel.fuelmid_session_cookie)")
        
        manager.requestSerializer.setValue(APILowLevel.USER_AGENT, forHTTPHeaderField: "User-Agent")
        manager.requestSerializer.setValue("fuelmid=\(APILowLevel.fuelmid_session_cookie)", forHTTPHeaderField: "Cookie")
  
        
        let onSucc: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->() = { task, responseObject in
            //Lo.yellow(responseObject)
            
            
            if let json = responseObject as? [String: String] {
                if json["code"] == "401" {
                    self.relogin(uri, parameters: parameters, success: success, failure: failure)
                    return
                }
            }
            
            success(task: task, responseObject: responseObject)
        }
        
        let onFail: (task: NSURLSessionDataTask!, error: NSError?)->() = { task, error in
            // failure will be passed through
            failure(task: task, error: error)
        }
        
        manager.GET(uri, parameters: parameters, success: onSucc, failure: onFail)
    }
    
    
}
