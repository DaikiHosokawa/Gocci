//
//  Network.swift
//  Gocci
//
//  Created by Ma Wa on 20.11.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


@objc class Network: NSObject, Logable {
    
    
    #if TEST_BUILD
    static var verbose: Bool = true
    #endif
    #if LIVE_BUILD
    static var verbose: Bool = false
    #endif
    
    
    static let logColor: (r: UInt8, g: UInt8, b: UInt8) = (0x99, 0x33, 0xCC)
    
    static let internetReachability: Reachability = Reachability.reachabilityForInternetConnection()
    
    static var waiters: [State->()] = []
    
    class func notifyMeForNetworkStatusChanges(f: State->()) {
        waiters.append(f)
    }

    enum State: Int {
        case OFFLINE
        case ONLINE_LAN
        case ONLINE_WAN
    }
    
    static var state: State = .OFFLINE
    
    static var offline: Bool { get { return state == .OFFLINE } }
    static var online: Bool { get { return state != .OFFLINE } }
    
    class func startNetworkStatusMonitoring() {
        internetReachability.startNotifier()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        let initialNote = NSNotification(name: kReachabilityChangedNotification, object: internetReachability)
        reachabilityChanged(initialNote)
    }
    
    class func reachabilityChanged(note: NSNotification) {
        if let reachabilty = note.object as? Reachability {
            let status = reachabilty.currentReachabilityStatus()
            
            let previous = state
            
            switch status.rawValue {
                case 0: state = .OFFLINE
                case 1: state = .ONLINE_LAN
                case 2: state = .ONLINE_WAN
                default: break
            }
            
            if previous == state {
                return
            }
            
            sep("NETWORK")
            log("Network state changed to:\t\(state)")
            
            for waiter in waiters {
                waiter(state)
            }
        }
    }
    
//    static let NETWORK_TIMEOUT = 20.0
    
//    class func makeRequest(url: NSURL) -> NSMutableURLRequest {
//        
//        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: NETWORK_TIMEOUT)
//        request.HTTPShouldHandleCookies = false
//        
//        return request
//        
//    }
    
    
    

    
//    class func performIgnoringRequestForJSON(
//        request: NSURLRequest,
//        onSuccess: ((statusCode: Int, data: NSData)->())?,
//        onFailure: ((errorMessage: String)->())? )
//    {
//        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//        config.allowsCellularAccess = true
//        // WARNING! ephemeral means nothing to disk. also NO COOKIES!!
//        let session = NSURLSession(configuration: config)
//        
//        let urlsessiontask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
//            
//            NSURLErrorNotConnectedToInternet
//            
//            guard error == nil else {
//                onFailure?(errorMessage: error?.localizedDescription ?? "No error message")
//                return
//            }
//            
//            guard let resp = response as? NSHTTPURLResponse else {
//                onFailure?(errorMessage: "Response is not an HTTP Response")
//                return
//            }
//            
//            guard let data = data else {
//                onFailure?(errorMessage: "No json data recieved")
//                return
//            }
//            
//            onSuccess?(statusCode: resp.statusCode, data: data)
//        }
//        
//        urlsessiontask.resume()
//    }
}
