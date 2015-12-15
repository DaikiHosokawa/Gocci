//
//  APISupport.swift
//  Gocci
//
//  Created by Markus Wanke on 22.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



func actualCode() {
    
    
    
    
//    let req = API3.auth.signup()
//    
//    req.parameters.username = "Peter Schmidt"
//
//    req.on_ERROR_USERNAME_ALREADY_REGISTERD { print( $0, ": ", $1) }
//    
//    req.perform { payload in
//        print(payload.identity_id)
//    }
//    
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
    
    
    
    static var fuelmid_session_cookie: String! = nil

#if TEST_BUILD
    static var verbose: Bool = true
    static var baseurl = API3.testurl
    static let USER_AGENT: String =
    "GocciTest/iOS/\(Util.getGocciVersionString()) API/\(API3.version) (\(Util.deviceModelName())/\(Util.operationSystemVersion()))"
#endif
#if LIVE_BUILD
    static var verbose: Bool = true
    static var baseurl = API3.liveurl
    static let USER_AGENT: String =
    "Gocci/iOS/\(Util.getGocciVersionString()) API/\(API3.version) (\(Util.deviceModelName())/\(Util.operationSystemVersion()))"
#endif
    
    enum NetworkError {
        case ERROR_UNKNOWN_ERROR_CODE
        case ERROR_NO_INTERNET_CONNECTION
        case ERROR_CONNECTION_FAILED
        case ERROR_CONNECTION_TIMEOUT
        case ERROR_SERVER_SIDE_FAILURE
        case ERROR_NO_DATA_RECIEVED
        case ERROR_BASEFRAME_JSON_MALFORMED
        case ERROR_RE_AUTH_FAILED
    }
    
    static let networkErrorMessageTable: [NetworkError: String] = [
        .ERROR_UNKNOWN_ERROR_CODE:
        "Unknown error code recieved",
        .ERROR_CONNECTION_FAILED:
        "Server connection failed",
        .ERROR_NO_INTERNET_CONNECTION:
        "The device appreas to be not connected to the internet",
        .ERROR_BASEFRAME_JSON_MALFORMED:
        "JSON response baseframe not parsable",
        .ERROR_SERVER_SIDE_FAILURE:
        "HTTP status differed from 200, indicationg failure on the server side",
        .ERROR_NO_DATA_RECIEVED:
        "Connection successful but no data recieved",
        .ERROR_CONNECTION_TIMEOUT:
        "Timeout reached before request finished",
        .ERROR_RE_AUTH_FAILED:
        "Reauthentication attempt failed",
    ]
    
    
    
    
    class func lo(msg: String) {
        if verbose {
            Lo.printInColor(0xFF, 0x99, 0x33, msg)
        }
    }
    
    class func sep(head: String) {
        if verbose {
            Lo.printInColor(0xFF, 0x99, 0x33, "=== API3: \(head) ============================================================================")
        }
    }
    
    /// Check the data and try to turn this into JSON
    class func preParseJSONResponse(data: NSData) -> (code: String, msg: String, payload:[String: JSON])? {
        
        let json = JSON(data: data)
        
        sep("RESPONSE")
        lo(json.rawString() ?? "Unparsable JSON")
        
        //guard let version = json["version"].int else { return nil }
        guard let code = json["code"].string else { return nil }
        guard let message = json["message"].string else { return nil }
        //guard version == 3 else { return nil }
        guard code != "" else { return nil }
        
        // TODO check for empty dict again when murata-san has fixed this bug
        let payload = json["payload"].dictionary ?? [:]
        
        //if code == "SUCCESS" && payload == nil { return nil }
        
        
        return (code: code, msg: message, payload: payload)
    }
    
    
    class func detectAndHandleGlobalErrors(code: String) -> API3.GlobalCode? {
        if code == "SUCCESS" {
            return nil // speedup
        }
        
        return API3.globalErrorReverseLookupTable[code]
    }
    

    
    class func NSURLErrorConversion(error: NSError) -> NetworkError {
        
        if error.domain == NSURLErrorDomain {
            
            if error.code == NSURLErrorNotConnectedToInternet {
                return .ERROR_NO_INTERNET_CONNECTION
            }
            if error.code == NSURLErrorTimedOut {
                return .ERROR_CONNECTION_TIMEOUT
            }
        }
        
        return .ERROR_CONNECTION_FAILED
    }
    
    // WARNING! ephemeral means nothing to disk. also NO COOKIES!! validate php feul session
    static let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    //static let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    
    class func extractFuelmidCookie(resp: NSHTTPURLResponse) {
        
        guard let headers = resp.allHeaderFields as? [String: String] else {
            return
        }
        
        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headers, forURL: NSURL(string: baseurl)!)
        
        for coo in cookies {
            //NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(coo)
            if coo.name == "fuelmid" {
                lo("Session Cookie: fuelmid=\(coo.value)")
                fuelmid_session_cookie = coo.value
            }
        }
    }
    
    class func performRelogin(var request: APIRequestProtocol, handleSaneJSONResponse:(code: String, message: String, payload: [String: JSON])->()) {
        
        sep("REAUTHENTICATION NEEDED")
        
        APIHighLevel.simpleLogin {
            if $0 {
                performNetworkRequest(request, handleSaneJSONResponse: handleSaneJSONResponse)
            }
            else {
                request.handleNetworkError(.ERROR_RE_AUTH_FAILED, networkErrorMessageTable[.ERROR_RE_AUTH_FAILED] ?? "No msg")
            }
        }
    
    }
    
    class func performNetworkRequest(var request: APIRequestProtocol, handleSaneJSONResponse:(code: String, message: String, payload: [String: JSON])->()) {
        
        guard let saneParameterPairs = request.validateParameterPairs() else {
            return
        }
        
        // if API.cacheable(apipath) && cached(apipath) && API.cacheTimeOut(apipath) > now - lastTimeCached(apipath)
        //      return getCacheEntry(apipath)
        
        
        let url = request.compose(saneParameterPairs)
        
        sep("REQUEST")
        for (k, v) in saneParameterPairs {
            lo("    \(k): \t\(v)")
        }
        lo(url.absoluteString)
        
        let req = NSMutableURLRequest(URL: url)
        
        req.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
        req.setValue("fuelmid=\(fuelmid_session_cookie)", forHTTPHeaderField: "Cookie")
        
        
        let urlsessiontask = session.dataTaskWithRequest(req) { (data, response, error) -> Void in
            
            guard error == nil else {
                request.handleNetworkError(NSURLErrorConversion(error!), error!.localizedDescription)
                return
            }
            
            guard let resp = response as? NSHTTPURLResponse where resp.statusCode == 200 else {
                request.handleNetworkError(.ERROR_SERVER_SIDE_FAILURE, networkErrorMessageTable[.ERROR_SERVER_SIDE_FAILURE] ?? "No msg")
                return
            }
            
            APISupport.extractFuelmidCookie(resp)
            
            guard let data = data where data.length > 0 else {
                request.handleNetworkError(.ERROR_NO_DATA_RECIEVED, networkErrorMessageTable[.ERROR_NO_DATA_RECIEVED] ?? "No msg")
                return
            }
            
            guard let (code, msg, payload) = preParseJSONResponse(data) else { // TODO CRC32 check in header field would be cool
                request.handleNetworkError(.ERROR_BASEFRAME_JSON_MALFORMED, networkErrorMessageTable[.ERROR_BASEFRAME_JSON_MALFORMED] ?? "No msg")
                return
            }
            
            guard API3.globalErrorReverseLookupTable[code] != API3.GlobalCode.ERROR_SESSION_EXPIRED else {
                performRelogin(request, handleSaneJSONResponse: handleSaneJSONResponse)
                return
            }
            
            guard API3.globalErrorReverseLookupTable[code] != API3.GlobalCode.ERROR_CLIENT_OUTDATED else {
                let pop = Util.overlayPopup("Yout Gocci version is outdated", "Please visit the AppStore and update Gocci")
                pop.addButton("Cancel", style: UIAlertActionStyle.Cancel) {  }
                pop.addButton("Open App Store", style: UIAlertActionStyle.Default) {
                    Util.openGocciInTheAppStore()
                }
                pop.overlay()
                return
            }
            
            guard code == "SUCCESS" || request.canHandleErrorCode(code) else {
                request.handleNetworkError(.ERROR_UNKNOWN_ERROR_CODE, networkErrorMessageTable[.ERROR_UNKNOWN_ERROR_CODE] ?? "No msg")
                return
            }
            
            
            handleSaneJSONResponse(code: code, message: msg, payload: payload)
        }
        
        urlsessiontask.resume()
    }
}














