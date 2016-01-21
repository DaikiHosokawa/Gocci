//
//  Util.swift
//  Gocci
//
//  Created by Markus Wanke on 19.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//
import Foundation
import UIKit





typealias OVF = (()->())?

@objc class Util : NSObject {
    
    
    class func absolutify(relativePath: String) -> NSURL {
        return NSFileManager.appRootDirectory().URLByAppendingPathComponent(relativePath)
    }
    
    
    
    class func mp4ForPostIDisAvailible(postID: String) -> NSURL? {
        var res: NSURL? = nil
        
        NSFileManager.postedVideosDirectory().treatAsDirectoryPathAndIterate { url in
            if url.absoluteString.hasSuffix("/" + postID + ".mp4") {
                res = url
            }
        }
        
        if res != nil {
            return res
        }
        
        NSFileManager.cachesDirectory().treatAsDirectoryPathAndIterate { url in
            if url.absoluteString.hasSuffix("/" + postID + ".mp4") {
                res = url
            }
        }
        
        return res
    }
    
    
    
    
    class func errorIsNetworkConfigurationError(error: NSError) -> Bool {
        switch error.code {
            // Maybe this list is incomplete
        case NSURLErrorNetworkConnectionLost: fallthrough
        case NSURLErrorNotConnectedToInternet: fallthrough
        case NSURLErrorCannotFindHost: fallthrough
        case NSURLErrorCannotConnectToHost: fallthrough
        case NSURLErrorDNSLookupFailed: fallthrough
        case NSURLErrorTimedOut:
            return true
        default:
            return false
        }
    }
    
    class func deleteAllCookies() {
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if cookieStorage.cookies != nil {
            for coo in cookieStorage.cookies! {
                print("Deleting Cookie: \(coo)")
                cookieStorage.deleteCookie(coo)
            }
        }
    }
    
    class func createTaskThatWillEvenRunIfTheAppIsPutInBackground(id: String, queue: dispatch_queue_t, task: ()->(), expirationHandler: ()->()) -> ()->() {
        
        var bgTask = UIBackgroundTaskInvalid
        
        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithName(id, expirationHandler: {
            
            expirationHandler()
            UIApplication.sharedApplication().endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskInvalid
        })
        
        return {
            dispatch_async(queue) {
                task()
                UIApplication.sharedApplication().endBackgroundTask(bgTask)
                bgTask = UIBackgroundTaskInvalid
            }
        }
    }
    
    class func sleep(secFraction: Double) {
        NSThread.sleepForTimeInterval(secFraction)
    }
    
    class func timestamp1970() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    
    class func timestampUTC() -> String {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss";
        return formatter.stringFromDate(date)
    }
    
    
    
    class func sleep(seconds: Int, and:()->Void) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC) )
        
        dispatch_after(popTime, dispatch_get_main_queue(), and)
    }
    
    class func overlayPopup(head: String, _ msg: String) -> UIAlertController {
        return UIAlertController.makeOverlayPopup(head, msg)
        
    }
    
    class func getUserDefString(key:String) -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey(key) as? String
    }
    //
    //    class func setUserDefString(key:String, value:String) {
    //        NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
    //        NSUserDefaults.standardUserDefaults().synchronize()
    //    }
    //
    //    class func setUserDefStrings(pairs: [String: String]) {
    //        for (k, v) in pairs {
    //            NSUserDefaults.standardUserDefaults().setValue(v, forKey: k )
    //        }
    //        NSUserDefaults.standardUserDefaults().synchronize()
    //    }
    
    class func thisKillsTheFacebook() {
        //        let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, HTTPMethod: "DELETE")
        //        deletepermission.startWithCompletionHandler({(connection,result,error)-> Void in
        //            print("the delete permission is \(result)")
        //
        //        })
        
        FBSDKLoginManager().logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
    }
    
    class func popup(msg: String, title: String = "", buttonText: String = "OK")
    {
        runOnMainThread{
            UIAlertView.init(title: title, message: msg, delegate: nil, cancelButtonTitle: buttonText).show()
        }
    }
    
    
    class func randomKanjiStringWithLength(len : Int) -> String {
        var res: [Character] = []
        res.reserveCapacity(len)
        
        for (var i = 0; i < len; i++){
            let rand = UInt16(0x4e00 + arc4random_uniform(UInt32(0x9faf - 0x4e00)))
            res.append(Character(UnicodeScalar(rand)))
        }
        
        return String(res)
    }
    
    class func randomAlphaNumericStringWithLength(len : Int) -> String {
        
        let letters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        var res: [Character] = []
        res.reserveCapacity(len)
        
        for (var i = 0; i < len; i++){
            let rand = Int(arc4random_uniform(UInt32(letters.count)))
            res.append(letters[rand])
        }
        
        return String(res)
    }
    
    
    
    class func randomUsername() -> String
    {
        let s1 = NSProcessInfo.processInfo().globallyUniqueString.characters.filter(){$0 != "-"}
        
        return String(s1[0..<5])
    }
    
    class func uniqueString() -> String {
        return NSProcessInfo.processInfo().globallyUniqueString
    }
    
    
    class func generateFakeDeviceID() -> String
    {
        // very cool language
        let s = NSProcessInfo.processInfo().globallyUniqueString.characters.filter(){$0 != "-"}
        
        return "00000000" + String(s[0..<48]) + "00000000"
    }
    
    
    
    //    class func getRegisterID() -> String {
    //
    //        //return generateFakeDeviceID()
    //
    //        let regid = Persistent.device_token
    //
    //        // Only Fake IDs in the simulator
    //        #if arch(i386) || arch(x86_64)
    //            return regid ?? generateFakeDeviceID()
    //        #else
    //            return regid ?? generateFakeDeviceID()
    //        #endif
    //    }
    
    
    
    class func runInBackground(block: ()->Void ) {
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, block)
    }
    
    class func runOnMainThread(block: ()->Void ) {
        if NSThread.isMainThread() {
            block()
        }
        else {
            dispatch_async(dispatch_get_main_queue(), block)
        }
    }
    
    class func getInchString() -> String
    {
        let height: Int = Int(UIScreen.mainScreen().bounds.size.height)
        
        let mappings = [
            480:  "3_5_inch",
            568:  "4_0_inch",
            667:  "4_7_inch",
            736:  "5_5_inch",
        ]
        
        if let correctFitting = mappings[height] {
            return correctFitting
        }
        
        // now we take the best alternative
        let closest = Algorithms.findNearestNumber(height, set: Array(mappings.keys))
        
        return mappings[closest!]!
    }
    
    class func getGocciVersionString() -> String {
        let dictionary = NSBundle.mainBundle().infoDictionary!
        return dictionary["CFBundleShortVersionString"] as! String
        //let build = dictionary["CFBundleVersion"] as? String
        //return "\(version ?? "") build \(build ?? "")"
    }
    
    class func wipeUserDataFromDevice(keepIdentityID: Bool) {
        var iid: String? = nil
        
        if keepIdentityID && Persistent.identity_id != nil {
            iid = Persistent.identity_id
        }
        
        Persistent.resetPersistentDataToInitialState()
        
        if keepIdentityID && iid != nil {
            Persistent.identity_id = iid
        }
    }
    
    class func operationSystemVersion() -> String {
        let ver = NSProcessInfo.processInfo().operatingSystemVersion
        return "\(ver.majorVersion).\(ver.minorVersion).\(ver.patchVersion)"
    }
    
    class func deviceModelName() -> String {
        // update with: https://stackoverflow.com/questions/26028918/ios-how-to-determine-iphone-model-in-swift/26962452#26962452
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    class func openGocciInTheAppStore() {
        UIApplication.sharedApplication().openURL(NSURL(string: GOCCI_APP_STORE_URL)!)
    }
}













