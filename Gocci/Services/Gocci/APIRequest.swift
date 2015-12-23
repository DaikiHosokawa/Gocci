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
    
    var privateNetworkTroublePreFilter: ((APILowLevel.NetworkError, String)->())? { get }
    
    
    func canHandleErrorCode(code: String) -> Bool
    
    func retry()
    
    func validateParameterPairs() -> [String: String]?
}


class APIRequest {
    
    var privateFirstRetry: Bool = true
    
    var privateNetworkTroublePreFilter: ((APILowLevel.NetworkError, String)->())? = nil
    
    func onNetworkTrouble(handler: (APILowLevel.NetworkError, String)->()) {
        privateNetworkTroublePreFilter = handler
    }
    
    var privateOnAllErrorsCallback: (()->())? = nil
    
    func onAnyAPIError(handler: ()->()) {
        privateOnAllErrorsCallback = handler
    }
}

extension APIRequestProtocol {
    
    mutating func handleNetworkError(code: APILowLevel.NetworkError, _ mmsg: String? = nil) {
        
        let msg = mmsg ?? APILowLevel.networkErrorMessageTable[.ERROR_BASEFRAME_JSON_MALFORMED] ?? "No error message defined"
        
        APILowLevel.sep("NETWORK ERROR OCCURED")
        APILowLevel.log("\(code): \(msg)")
        
        if privateFirstRetry && Network.online {
            APILowLevel.sep("RETRY HELP")
            APILowLevel.log("Request failed on network error: \(code). We perform one RETRY")
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
    
    // TODO TRANSLATION
    mutating func defaultOnNetworkFailure(error: APILowLevel.NetworkError, _ message: String) {
        
        // the user is not in WLAN or WWAN
        if error == .ERROR_NO_INTERNET_CONNECTION {
            let pop = Util.overlayPopup("通信が失敗しました", "ネットワークがありません")
            pop.addButton("諦める", style: UIAlertActionStyle.Cancel) {  }
            pop.addButton("もう一度", style: UIAlertActionStyle.Default) { self.retry() }
            pop.overlay()
        }
        // all the other error that can happen in the internet. Time out, packet loss, our server crashed, no DNS server, gocci server down, JSON is malfored...
        else {
#if TEST_BUILD
            let pop = Util.overlayPopup("通信が失敗しました", "\(error)\n\(message)")
#else
            let pop = Util.overlayPopup("通信が失敗しました", "ネットワークに問題があります")
#endif
            pop.addButton("諦める", style: UIAlertActionStyle.Cancel) {  }
            pop.addButton("もう一度", style: UIAlertActionStyle.Default) { self.retry() }
            pop.overlay()
        }
        
        
    }
    
    func compose(saneParameterPairs: [String: String]) -> NSURL {
        let res = NSURLComponents(string: APILowLevel.baseurl + apipath)!
        res.queryItems = saneParameterPairs.map{ (k,v) in NSURLQueryItem(name: k, value: v) }
        return res.URL!
    }
    
    
}
