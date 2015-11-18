//
//  TwitterLowLevel.swift
//  Gocci
//
//  Created by Ma Wa on 18.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


class TwitterLowLevel {
    
    enum TwitterLowLevelError: ErrorType {
        case ERROR_NETWORK(String)
        case ERROR_TWITTER_API(String)
        case ERROR_AUTHENTICATION
    }
    
    class func twitterErrorJSONtoString(json: JSON) -> String {
        // EXPECT {"errors":[{"code":44,"message":"media_ids parameter is invalid."}]}
        var emsgs: [String] = []
        for (_, err):(String, JSON) in json["errors"] {
            if let e = err["message"].string { emsgs.append(e) }
        }
        let res = ", ".join(emsgs)
        
        if !res.isEmpty {
            return res
        }
        
        return json["error"].string ?? json.rawString() ?? "JSON Unparsable"
    }
    
    class func makeFormdataStringFromDictonary(dict: [String: String]) -> String {
        // WARNING: The order of the parameters has to be alphabetically!! media_ids BEFORE status!!
        let sortedDict = dict.sort { $0.0 < $1.0 }
        
        let pairs = sortedDict.map { $0.0 + "=" + $0.1.percentEncodingSane() }
        return "&".join(pairs)
    }
    
    
    class func performGETRequest(var url: NSURL, parameters: [String: String],
        onSuccess: (jsonResponse: JSON)->(),
        onFailure: (error: TwitterLowLevelError)->())
    {
        guard let key = TwitterAuthentication.token?.user_key, secret = TwitterAuthentication.token?.user_secret else {
            onFailure(error: .ERROR_AUTHENTICATION)
            return
        }
        
        let auth = ServiceUtil.createOAuthSignatureHeaderEntry(key, userSecret: secret, HTTPMethod: "GET", baseURL: url, unencodedPOSTParameters: parameters)
        
        if !parameters.isEmpty {
            let formdata = makeFormdataStringFromDictonary(parameters)

            if let nurl = NSURL(string: url.absoluteString + "?" + formdata) {
                url = nurl
            }
            else {
                onFailure(error: .ERROR_NETWORK("GET parameter malformed"))
            }
        }
        
        performRequest("GET", url: url, authorization: auth, parameters: parameters, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    class func performPOSTRequest(url: NSURL, parameters: [String: String],
        onSuccess: (jsonResponse: JSON)->(),
        onFailure: (error: TwitterLowLevelError)->())
    {
        guard let key = TwitterAuthentication.token?.user_key, secret = TwitterAuthentication.token?.user_secret else {
            onFailure(error: .ERROR_AUTHENTICATION)
            return
        }
        
        let auth = ServiceUtil.createOAuthSignatureHeaderEntry(key, userSecret: secret, HTTPMethod: "POST", baseURL: url, unencodedPOSTParameters: parameters)
        
        performRequest("POST", url: url, authorization: auth, parameters: parameters, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    private class func performRequest(type: String, url: NSURL, authorization: String, parameters: [String: String],
        onSuccess: (jsonResponse: JSON)->(),
        onFailure: (error: TwitterLowLevelError)->())
    {
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: 30.0)
        request.HTTPMethod = type
        request.HTTPShouldHandleCookies = false
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        
        
        if type == "POST" {
            let formdata = makeFormdataStringFromDictonary(parameters)
            
            guard let data = formdata.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) else {
                onFailure(error: .ERROR_NETWORK("Formdata conversion failed"))
                return
            }
            
            request.setValue(String(data.length), forHTTPHeaderField: "Content-Length")
            request.HTTPBody = data
        }
        
        ServiceUtil.performRequest(request,
            onSuccess: { (statusCode, data) -> () in
                if statusCode >= 200 && statusCode < 300 {
                    onSuccess(jsonResponse: JSON(data: data))
                }
                else {
                    onFailure(error: .ERROR_TWITTER_API(twitterErrorJSONtoString(JSON(data: data))))
                }
            },
            onFailure: { errorMessage in
                onFailure(error: .ERROR_NETWORK(errorMessage))
            }
        )
    }
}