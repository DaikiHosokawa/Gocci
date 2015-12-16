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
    
    
    func GET(uri: String, parameters: NSDictionary,
        success: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->(),
        failure: (task: NSURLSessionDataTask!, error: NSError?)->())
    {
        print("GET calledfor: \(uri)")
        
        manager.requestSerializer.setValue(APISupport.USER_AGENT, forHTTPHeaderField: "User-Agent")
        manager.requestSerializer.setValue("fuelmid=\(APISupport.fuelmid_session_cookie)", forHTTPHeaderField: "Cookie")
  
        
        let onSucc: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->() = { task, responseObject in
            
            
            if let json = responseObject as? [String: String] {
                if json["code"] == "401" {
                    print("401: UNATHENTICATED!! performing relogin... ")
                    
                    APIHighLevel.simpleLogin { succ in
                        if succ {
                            self.manager.requestSerializer.setValue(APISupport.USER_AGENT, forHTTPHeaderField: "User-Agent")
                            self.manager.requestSerializer.setValue("fuelmid=\(APISupport.fuelmid_session_cookie)", forHTTPHeaderField: "Cookie")
                            
                            self.manager.GET(uri, parameters: parameters, success: success, failure: failure)
                        }
                        else if let _ = task.response as? NSHTTPURLResponse {
                            let uidict = [NSLocalizedDescriptionKey: "Authentitication on relogin failed. should never happen"]
                            failure(task: task, error: NSError(domain: "com.gocci.network", code: 401, userInfo: uidict))
                        }
                        // if it is not castable we stop here. because it would crash in APIClient after that
                    }
                }
                else {
                    success(task: task, responseObject: responseObject)
                }
            }
            else {
                success(task: task, responseObject: responseObject)
            }
            
        }
        
        let onFail: (task: NSURLSessionDataTask!, error: NSError?)->() = { task, error in
            // failure will be passed through
            failure(task: task, error: error)
        }
        
        manager.GET(uri, parameters: parameters, success: onSucc, failure: onFail)
    }
    
    
}
