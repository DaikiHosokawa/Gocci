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
    
    var firstRetry: Bool { get set }
    
    var networkTroublePreFilter: ((APISupport.NetworkError, String)->())? { get }
    
    
    func canHandleErrorCode(code: String) -> Bool
    
    func retry()
    
    func validateParameterPairs() -> [String: String]?
}


class APIRequest {
    
    var firstRetry: Bool = true
    
    var networkTroublePreFilter: ((APISupport.NetworkError, String)->())? = nil
    
    func onNetworkTrouble(handler: (APISupport.NetworkError, String)->()) {
        networkTroublePreFilter = handler
    }
}

extension APIRequestProtocol {
    
    mutating func handleNetworkError(code: APISupport.NetworkError, _ msg: String) {
        
        if firstRetry && Network.online {
            APISupport.sep("RETRY HELP")
            APISupport.lo("Request failed on network error: \(code). We perform one RETRY")
            firstRetry = false
            self.retry()
            return
        }
        
        Util.runOnMainThread{
            if self.networkTroublePreFilter != nil {
                self.networkTroublePreFilter?(code, msg)
            }
            else {
                self.defaultOnNetworkFailure(code, msg)
            }
        }
    }
    
    mutating func defaultOnNetworkFailure(error: APISupport.NetworkError, _ message: String) {
        
        let pop = Util.overlayPopup("Network request failed", "Maybe there is something wrong with your internet connection\n\(error) : \(message)")
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
