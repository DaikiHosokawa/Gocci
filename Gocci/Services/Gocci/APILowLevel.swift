//
//  APILowLevel.swift
//  Gocci
//
//  Created by Markus Wanke on 22.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class APILowLevel: Logable {
    
    static var verbose: Bool = true
    static let logColor: (r: UInt8, g: UInt8, b: UInt8) = (0xFF, 0x99, 0x33)
    
    
    static var fuelmid_session_cookie: String! = nil

#if TEST_BUILD
    static var baseurl = API3.testurl
    static let USER_AGENT: String =
    "GocciTest/iOS/\(Util.getGocciVersionString()) API/\(API3.version) (\(Util.deviceModelName())/\(Util.operationSystemVersion()))"
#endif
#if LIVE_BUILD
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
    

    
    /// Check the data and try to turn this into JSON
    class func preParseJSONResponse(data: NSData) -> (code: String, msg: String, payload:[String: JSON])? {
        
        let json = JSON(data: data)
        
        sep("RESPONSE")
        log(json.rawString() ?? "Unparsable JSON")
        
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
                log("Session Cookie: fuelmid=\(coo.value)")
                fuelmid_session_cookie = coo.value
            }
        }
    }
    
    class func performRelogin(var request: APIRequestProtocol, handleSaneJSONResponse:(code: String, message: String, payload: [String: JSON])->()) {
        
        sep("REAUTHENTICATION NEEDED")
        
        guard let iid = Persistent.identity_id ?? Util.getUserDefString("identity_id") else {
            request.handleNetworkError(.ERROR_RE_AUTH_FAILED, "No IID! Make an account first!")
            return
        }
        
        let req = API3.auth.login()
        
        req.parameters.identity_id = iid
        
        req.onAnyAPIError {
            request.handleNetworkError(.ERROR_RE_AUTH_FAILED, "Local error occured. IID wrong format or not registerd?")
        }
        
        req.onNetworkTrouble { c, m -> () in
            Lo.error("API Login: \(c): \(m)")
            // we push this to the original network error handler.
            // this is needed so that bg tasks don't activate popups
            request.handleNetworkError(c, m)
        }
        
        req.perform { (payload) -> () in
            APIHighLevel.stepTwo(payload) { awsLoginSuccess in
                if awsLoginSuccess {
                    performNetworkRequest(request, handleSaneJSONResponse: handleSaneJSONResponse)
                }
                else {
                    Lo.error("API Login: AWS Login Failed. ignored... ")
                    performNetworkRequest(request, handleSaneJSONResponse: handleSaneJSONResponse)
                }
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
            log("    \(k): \t\(v)")
        }
        log("URL:  " + url.absoluteString)
        
        let req = NSMutableURLRequest(URL: url)
        
        req.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
        req.setValue("fuelmid=\(fuelmid_session_cookie)", forHTTPHeaderField: "Cookie")
        
        
        let urlsessiontask = session.dataTaskWithRequest(req) { (data, response, error) -> Void in
            
            guard error == nil else {
                request.handleNetworkError(NSURLErrorConversion(error!), error!.localizedDescription)
                return
            }
            
            guard let resp = response as? NSHTTPURLResponse where resp.statusCode == 200 else {
                request.handleNetworkError(.ERROR_SERVER_SIDE_FAILURE)
                return
            }
            
            APILowLevel.extractFuelmidCookie(resp)
            
            guard let data = data where data.length > 0 else {
                request.handleNetworkError(.ERROR_NO_DATA_RECIEVED)
                return
            }
            
            guard let (code, msg, payload) = preParseJSONResponse(data) else { // TODO CRC32 check in header field would be cool
                request.handleNetworkError(.ERROR_BASEFRAME_JSON_MALFORMED)
                return
            }
            
            guard API3.globalErrorReverseLookupTable[code] != API3.GlobalCode.ERROR_SESSION_EXPIRED else {
                performRelogin(request, handleSaneJSONResponse: handleSaneJSONResponse)
                return
            }
            
            guard API3.globalErrorReverseLookupTable[code] != API3.GlobalCode.ERROR_CLIENT_OUTDATED else {
                let pop = Util.overlayPopup("あなたのGocciは古いバージョンです", "AppStoreでアップデートしてください")
                pop.addButton("Cancel", style: UIAlertActionStyle.Cancel) {  }
                pop.addButton("AppStoreへ", style: UIAlertActionStyle.Default) {
                    Util.openGocciInTheAppStore()
                }
                pop.overlay()
                return
            }
            
            guard code == "SUCCESS" || request.canHandleErrorCode(code) else {
                request.handleNetworkError(.ERROR_UNKNOWN_ERROR_CODE)
                return
            }
            
            
            handleSaneJSONResponse(code: code, message: msg, payload: payload)
        }
        
        urlsessiontask.resume()
    }
    
    
    
    
    class func cacheFile(url: NSURL, filename:String, and: NSURL?->()) {
        
        log("Simple File Download: " + url.absoluteString)
        
        let req = NSMutableURLRequest(URL: url)
        
        req.setValue(USER_AGENT, forHTTPHeaderField: "User-Agent")
        req.setValue("fuelmid=\(fuelmid_session_cookie)", forHTTPHeaderField: "Cookie")
        
        let task = session.downloadTaskWithRequest(req) { location, response, error in
            
            guard error == nil else {
                and(nil)
                return
            }
            
            guard let resp = response as? NSHTTPURLResponse where resp.statusCode == 200 else {
                and(nil)
                return
            }
            
            guard let location = location else {
                and(nil)
                return
            }
            
            let fm = NSFileManager.defaultManager()
            let target = NSFileManager.cachesDirectory().URLByAppendingPathComponent(filename)
            
            let _ = try? fm.removeItemAtURL(target)
            
            do {
                try fm.moveItemAtURL(location, toURL: target)
            }
            catch {
                and(nil)
                return
            }

            log("download complete: \(target)")
            
            and(target)
        }
        
        task.resume()
    }
}








