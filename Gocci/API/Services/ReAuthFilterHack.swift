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
        
        manager = AFHTTPSessionManager(baseURL: withBaseURL)
     
        manager.responseSerializer.acceptableContentTypes = Set(["application/json", "text/html", "text/javascript"])
    }
    
    
    func relogin(andThen: Bool->()) {
        
        let handleNetOpResult: (NetOpResult, String!) -> () = { code, msg in
            
            // There should never be an case where anything other then NETOP_SUCCESS is
            // the result, because the user already has an account at this point.
            switch code {
                case NetOpResult.NETOP_SUCCESS:
                    AWS2.connectToBackEndWithUserDefData().continueWithBlock({ (task) -> AnyObject! in
                        andThen(true)
                        return nil
                    })
                default:
                    andThen(false)
            }
        }
        
        
        if let iid = Util.getUserDefString("iid") {            NetOp.loginWithIID(iid, andThen: handleNetOpResult)
        }
        else {
            andThen(false)
        }
    }
    
    func GET(uri: String, parameters: NSDictionary,
        success: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->(),
        failure: (task: NSURLSessionDataTask!, error: NSError?)->())
    {
        print("GET calledfor: \(uri)")
        
        
        let onSucc: (task: NSURLSessionDataTask!, responseObject: AnyObject?)->() = { task, responseObject in
            
            if let json = responseObject as? [String: String] {
                if json["code"] == "401" {
                    print("401: UNATHENTICATED!! performing relogin... ")
                    
                    self.relogin { succ in
                        if succ {
                            self.manager.GET(uri, parameters: parameters, success: success, failure: failure)
                        }
                        else if let _ = task.response as? NSHTTPURLResponse {
//                            task.response.statusCode = 401
                            
                            let uidict = [NSLocalizedDescriptionKey: "Authentitication on relogin failed. should never happen"]
                            failure(task: task, error: NSError(domain: "com.gocci.network", code: 401, userInfo: uidict))
                        }
                        // is it is not castable we stop here. because it would crash in APIClient after that
                    }
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
