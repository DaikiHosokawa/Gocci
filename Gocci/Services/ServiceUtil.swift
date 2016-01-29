
//
//  ServiceUtil.swift
//  Gocci
//
//  Created by Markus Wanke on 09.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



class ServiceUtil {
    
    class FormData {
        static let NL = "\r\n"
        
        let boundary = Util.randomAlphaNumericStringWithLength(32)
        
        let bodydata = NSMutableData()

        func appendDisposition(name name: String, value: String, header:[String: String]? = nil) {
            var head = "--" + boundary + FormData.NL
            head += "Content-Disposition: form-data; name=\"\(name)\""  + FormData.NL
            if let header = header {
                for (k, v)in header {
                    head += "\(k): \(v)" + FormData.NL
                }
            }
            head += FormData.NL + value + FormData.NL
            bodydata.appendData(head.asUTF8Data())
        }
        
        func appendFileDisposition(name name: String, filename: String, data:NSData, header:[String: String]? = nil) {
            var head = "--" + boundary + FormData.NL
            head += "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"" + FormData.NL
            head += "Content-Type: application/octet-stream" + FormData.NL
            if let header = header {
                for (k, v)in header {
                    head += "\(k): \(v)" + FormData.NL
                }
            }
            head += FormData.NL
            bodydata.appendData(head.asUTF8Data())
            bodydata.appendData(data)
            bodydata.appendData(FormData.NL.asUTF8Data())
        }
        
        func generateRequestBody() -> NSData {
            let finalBoundary = "--" + boundary + "--" + FormData.NL
            bodydata.appendData(finalBoundary.asUTF8Data())
            return bodydata
        }
        
    }
    
    
    
    static let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    
    class func performRequest(
        request: NSURLRequest,
        onSuccess: ((statusCode: Int, data: NSData)->())?,
        onFailure: ((errorMessage: String)->())? )
    {
        let urlsessiontask = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                onFailure?(errorMessage: error?.localizedDescription ?? "No error message")
                return
            }
            
            guard let resp = response as? NSHTTPURLResponse else {
                onFailure?(errorMessage: "Response is not an HTTP Response")
                return
            }
            
            guard let data = data else {
                onFailure?(errorMessage: "No json data recieved")
                return
            }
            
            onSuccess?(statusCode: resp.statusCode, data: data)
        }
        
        urlsessiontask.resume()
    }



    
    private class func generateOAuthNonce() -> String
    {
        let s1 = NSProcessInfo.processInfo().globallyUniqueString.characters.filter(){$0 != "-"}
        
        return String(s1[0..<32]).lowercaseString
    }
    
    class func createOAuthSignatureHeaderEntry(
        userKey: String,
        userSecret: String,
        HTTPMethod: String,
        baseURL: NSURL,
        unencodedPOSTParameters: [String: String]) -> String
    {
        // everything what happens here: https://dev.twitter.com/oauth/overview/creating-signatures
        // this needs #import <CommonCrypto/CommonCrypto.h> in the bridging header
        
        var oAuthParameters: [String: String] = [
            "oauth_consumer_key":     TWITTER_CONSUMER_KEY,
            "oauth_nonce":            generateOAuthNonce(),
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp":        String(Util.timestamp1970()),
            "oauth_token":            userKey,
            "oauth_version":          "1.0"
        ]
        
        var toBeSigned: [(key: String, value: String)] = []
        
        for (k, v) in oAuthParameters {
            toBeSigned.append((k,v))
        }
        for (k, v) in unencodedPOSTParameters {
            toBeSigned.append((k,v))
        }
        
        let encodedPairs = toBeSigned.map { (key: $0.key.percentEncodingOAuthStyle(), value: $0.value.percentEncodingOAuthStyle()) }
        
        let sortedPairs = encodedPairs.sort { $0.key < $1.key }
        
        let pairStrings = sortedPairs.map { $0.key + "=" + $0.value }
        
        let signString = "&".join(pairStrings)
        
        let signatureBaseStringPrefix = HTTPMethod.uppercaseString + "&" + baseURL.absoluteString.percentEncodingOAuthStyle() + "&"
        let signatureBaseString = signatureBaseStringPrefix + signString.percentEncodingOAuthStyle()
        
        let signingKey = TWITTER_CONSUMER_SECRET.percentEncodingOAuthStyle() + "&" + userSecret.percentEncodingOAuthStyle()
        
        
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        let buf = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.length, signatureBaseString, signatureBaseString.length, buf)
        let data = NSData(bytesNoCopy: buf, length: digestLen, freeWhenDone: true)
        
        let signature = data.base64Encode()
        
        oAuthParameters["oauth_signature"] = signature
        
        let oAuthPairs = oAuthParameters.map { ( key: $0.percentEncodingOAuthStyle(), value: $1.percentEncodingOAuthStyle() ) }
        let oAuthSortedPairs = oAuthPairs.sort { $0.key < $1.key }
        let oAuthPairStrings = oAuthSortedPairs.map { $0.key + "=" + $0.value.brackify() }
        
        return "OAuth " + ", ".join(oAuthPairStrings)
    }
}

















