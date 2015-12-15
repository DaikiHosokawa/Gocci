//
//  APIRequest.swift
//  Gocci
//
//  Created by Ma Wa on 14.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation



protocol APIRequestProtocol {
    
    var apipath: String { get }
    
    var privateFirstRetry: Bool { get set }
    
    var privateNetworkTroublePreFilter: ((APISupport.NetworkError, String)->())? { get }
    
    
    func canHandleErrorCode(code: String) -> Bool
    
    func retry()
    
    func validateParameterPairs() -> [String: String]?
}


class APIRequest {
    
    var privateFirstRetry: Bool = true
    
    var privateNetworkTroublePreFilter: ((APISupport.NetworkError, String)->())? = nil
    
    func onNetworkTrouble(handler: (APISupport.NetworkError, String)->()) {
        privateNetworkTroublePreFilter = handler
    }
    
    var privateOnAllErrorsCallback: (()->())? = nil
    
    func onAnyAPIError(handler: ()->()) {
        privateOnAllErrorsCallback = handler
    }
}

extension APIRequestProtocol {
    
    mutating func handleNetworkError(code: APISupport.NetworkError, _ mmsg: String? = nil) {
        
        let msg = mmsg ?? APISupport.networkErrorMessageTable[.ERROR_BASEFRAME_JSON_MALFORMED] ?? "No error message defined"
        
        APISupport.sep("NETWORK ERROR OCCURED")
        APISupport.lo("\(code): \(msg)")
        
        if privateFirstRetry && Network.online {
            APISupport.sep("RETRY HELP")
            APISupport.lo("Request failed on network error: \(code). We perform one RETRY")
            privateFirstRetry = false
            self.retry()
            return
        }
        
        Util.runOnMainThread{
            if let ownNetworkTroubleHandler = self.privateNetworkTroublePreFilter {
                ownNetworkTroubleHandler(code, msg)
            }
            else {
                self.defaultOnNetworkFailure(code, msg)
            }
        }
    }
    
    mutating func defaultOnNetworkFailure(error: APISupport.NetworkError, _ message: String) {
        
        let pop = Util.overlayPopup("Network request failed", "Maybe there is something wrong with your internet connection\n\(error)")
        pop.addButton("Give up", style: UIAlertActionStyle.Cancel) {  }
        pop.addButton("Retry", style: UIAlertActionStyle.Default) {
            self.retry()
        }
        
        pop.overlay()
    }
    
    func compose(saneParameterPairs: [String: String]) -> NSURL {
        let res = NSURLComponents(string: APISupport.baseurl + apipath)!
        res.queryItems = saneParameterPairs.map{ (k,v) in NSURLQueryItem(name: k, value: v) }
        return res.URL!
    }
    
    
}
