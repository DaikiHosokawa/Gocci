//
//  APISupport.swift
//  Gocci
//
//  Created by Markus Wanke on 22.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



func actualCode() {
    
    
    
    
    let req = API3.auth.signup()
    
    req.parameters.username = "Peter Schmidt"

    req.on_ERROR_USERNAME_ALREADY_REGISTERD { print( $0, ": ", $1) }
    
    req.perform { payload in
        print(payload.identity_id)
    }
    
    //
    //    API2.on(API2.GlobalCode.ERROR_NO_INTERNET_CONNECTION){
    //        print("ERROR: \($0): \($1)")
    //    }
    //
    //    let req = API2.auth.login()
    //    req.identity_id = "us-east-1:a42b874a-8791-4fba-b5a0-f00b8c0162aa"
    //
    //    req.on(API2.auth.login.LocalCode.ERROR_RESPONSE_IDENTITY_ID_MALFORMED){
    //        print("ERROR: \($0): \($1)")
    //    }
    //
    //    req.perform(){ (payload) in
    //        print(payload.username)
    //    }
}



class APISupport {
    
    // TODO remove this, is now a string extension
    /// Simple String regex matching helper
    class func matches(s:String, re:String) -> Bool {
        let regex = try! NSRegularExpression(pattern: re, options: [])
        return regex.firstMatchInString(s, options:[], range: NSMakeRange(0, s.characters.count)) != nil
    }
    
    
    /// Check the data and try to turn this into JSON
    class func preParseJSONResponse(data: NSData) -> (frame:[String:String], payload:[String:AnyObject])? {
        
        // Valif JSON over test
        guard let jsonraw = try? NSJSONSerialization.JSONObjectWithData(data, options:.MutableContainers) else {
            return nil
        }
        
        // toplevel keys are strings test
        guard var jsondict = jsonraw as? [String:AnyObject] else {
            return nil
        }
        
        // there is a key named payload, if yes we remove it
        guard let payload = jsondict.removeValueForKey("api_payload") as? [String:AnyObject] else {
            return nil
        }
        
        // Now we convert [String:AnyObject] to [String:String] for the frame to reduce castings
        guard let frame = jsondict as? [String:String] else {
            return nil
        }
        
        guard validateJSONResponseFrame(frame) else {
            return nil
        }
        
        return (frame: frame, payload: payload)
    }
    
    /// Check the baseframe for the main components
    class func validateJSONResponseFrame(frame: [String: String]) -> Bool {
        return frame["api_version"] != nil && frame["api_code"] != nil && frame["api_uri"] != nil && frame["api_message"] != nil
    }
    
    class func detectAndHandleGlobalErrors(code: String) -> API3.GlobalCode? {
        if code == "SUCCESS" {
            return nil // speedup
        }
        
        return API3.globalErrorReverseLookupTable[code]
    }
    
    class func handleCommunicationFailure(communicationErrorCode: API3.GlobalCode, emsg: String? = nil) {
        
        let demsg = API3.globalErrorMessageTable[communicationErrorCode] ?? "No error message defined for this error"
        
        if let handler = API3.globalErrorMapping[communicationErrorCode] {
            dispatch_async(dispatch_get_main_queue()) {
                handler(communicationErrorCode, emsg ?? demsg)
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                API3.onUnhandledError(communicationErrorCode, emsg ?? demsg)
            }
        }
    }
    
    class func NSURLErrorConversion(error: NSError) -> API3.GlobalCode {
        
        if error.domain == NSURLErrorDomain {
            
            if error.code == NSURLErrorNotConnectedToInternet {
                return .ERROR_NO_INTERNET_CONNECTION
            }
            if error.code == NSURLErrorTimedOut {
                return .ERROR_CONNECTION_TIMEOUT
            }
            
            return .ERROR_CONNECTION_FAILED
        }
        
        return .ERROR_UNKNOWN_ERROR
    }
    
    class func performNetworkRequest(request: APIRequestProtocol, handleSaneJSONResponse:(code: String, message: String, payload: [String: AnyObject])->()) {
        
        guard let saneParameterPairs = request.validateParameterPairs() else {
            return
        }
        
        
        // if API.cacheable(apipath) && cached(apipath) && API.cacheTimeOut(apipath) > now - lastTimeCached(apipath)
        //      return getCacheEntry(apipath)
        
        
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.allowsCellularAccess = true
        // WARNING! ephemeral means nothing to disk. also NO COOKIES!! validate php feul session
        let session = NSURLSession(configuration: config)
        
        
        let req = NSURLRequest(URL: request.compose(saneParameterPairs))
        
        let urlsessiontask = session.dataTaskWithRequest(req) { (data, response, error) -> Void in
            
            if NSThread.currentThread().isMainThread {
                NSLog("Warning! You are downloading on the main thread, blocking UI stuff etc...")
            }
            
            guard error == nil else {
                handleCommunicationFailure(NSURLErrorConversion(error!), emsg: error!.localizedDescription)
                return
            }
            
            guard let resp = response as? NSHTTPURLResponse where resp.statusCode == 200 else {
                handleCommunicationFailure(.ERROR_SERVER_SIDE_FAILURE)
                return
            }
            
            guard let data = data where data.length > 0 else {
                handleCommunicationFailure(.ERROR_NO_DATA_RECIEVED)
                return
            }
            
            guard let (frame, payload) = preParseJSONResponse(data) else { // TODO CRC32 check in header field would be cool
                handleCommunicationFailure(.ERROR_BASEFRAME_JSON_MALFORMED)
                return
            }
            
            if let globalError = detectAndHandleGlobalErrors(frame["api_code"]!) {
                handleCommunicationFailure(globalError, emsg: frame["api_message"])
                return
            }
            
            handleSaneJSONResponse(code: frame["api_code"]!, message: frame["api_message"]!, payload: payload)
        }
        
        urlsessiontask.resume()
    }
}



protocol APIRequestProtocol {
    
    var apipath: String { get }
    
    func validateParameterPairs() -> [String: String]?
    
}


extension APIRequestProtocol {
    
    func compose(saneParameterPairs: [String: String]) -> NSURL {
        let res = NSURLComponents(string: API3.baseurl + apipath)!
        // 素敵なコード書きましょう〜
        res.queryItems = saneParameterPairs.map{ (k,v) in NSURLQueryItem(name: k, value: v) }
        return res.URL!
    }
    
    
}