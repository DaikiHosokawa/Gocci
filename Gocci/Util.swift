
//
//  Util.swift
//  Gocci
//
//  Created by Ma Wa on 19.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//




import Foundation
import UIKit



@objc class Util : NSObject {
    
    //    class func delme() {
    //        let dataFromString = "{wdwdwdw}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    //
    //        let json = JSON(data: dataFromString!)
    //        print(json)
    //
    //    }
    
    
    
    
    // THIS is a ugly hack until the tutorial page view controller is rewritten in swift
    class func dirtyBackEndLoginWithUserDefData() -> AWSTask {
        return AWS2.connectToBackEndWithUserDefData().continueWithBlock({ (task) -> AnyObject! in
            AWS2.storeTimeInLoginDataSet()
            return nil
        })
    }
    
    // THIS is a ugly hack until the tutorial page view controller is rewritten in swift
    class func dirtyBackEndSignUpWithUserDefData() -> AWSTask {
        return AWS2.connectToBackEndWithUserDefData().continueWithBlock({ (task) -> AnyObject! in
            AWS2.storeSignUpDataInCognito(Util.getUserDefString("username") ?? "no username set")
            return nil
        })
    }
    
    class func sleep(seconds: Int, and:()->Void) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds) * Int64(NSEC_PER_SEC) )
        
        dispatch_after(popTime, dispatch_get_main_queue(), and)
    }
    
    class func getUserDefString(key:String) -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey(key) as? String
    }
    
    class func setUserDefString(key:String, value:String) {
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func setUserDefStrings(pairs: [String: String]) {
        for (k, v) in pairs {
            NSUserDefaults.standardUserDefaults().setValue(v, forKey: k )
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func thisKillsTheFacebook() {
        let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, HTTPMethod: "DELETE")
        deletepermission.startWithCompletionHandler({(connection,result,error)-> Void in
            print("the delete permission is \(result)")
            
        })
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
        
        FBSDKLoginManager().logOut()
        
    }
    
    class func popup(msg: String, title: String = "", buttonText: String = "OK")
    {
        UIAlertView.init(title: title, message: msg, delegate: nil, cancelButtonTitle: buttonText).show()
    }
    
    class func setBadgeNumber(numberOfNewMessages: Int)
    {
        // TODO I don"t see a reason this has to got to user defaults, however it is read in over 20 places from ud,
        // so this will be fixed in the next version of gocci
        NSUserDefaults.standardUserDefaults().setInteger(numberOfNewMessages, forKey: "numberOfNewMessages")
        
        if numberOfNewMessages > 0 {
            UIApplication.sharedApplication().applicationIconBadgeNumber = numberOfNewMessages
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
    
    
    class func generateFakeDeviceID() -> String
    {
        // very cool language
        let s = NSProcessInfo.processInfo().globallyUniqueString.characters.filter(){$0 != "-"}
        
        return "00000000" + String(s[0..<48]) + "00000000"
    }
    
    class func getRegisterID() -> String {
        
        //return generateFakeDeviceID()
        
        let regid = NSUserDefaults.standardUserDefaults().stringForKey("register_id")
        
        // Only Fake IDs in the simulator
        #if arch(i386) || arch(x86_64)
            return regid ?? generateFakeDeviceID()
        #else
            return regid ?? "CANT_DETERMINE_DEVICE_ID"
        #endif
    }
    
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
    
    class func removeAccountSpecificDataFromUserDefaults()
    {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_id")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("profile_img")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("iid")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("badge_num")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
    }
    
    class func getInchString() -> String
    {
        switch UIScreen.mainScreen().bounds.size.height
        {
        case 480: return "3_5_inch"
        case 568: return "4_0_inch"
        case 667: return "4_7_inch"
        case 736: return "5_5_inch"
            
        default:
            NSLog("no known inch size for \(UIScreen.mainScreen().bounds.size.height) pixels height")
            return "no known inch size for \(UIScreen.mainScreen().bounds.size.height) pixels height"
        }
    }
    
    class func getGocciVersionString() -> String? {
        let dictionary = NSBundle.mainBundle().infoDictionary!
        return dictionary["CFBundleShortVersionString"] as? String
        //let build = dictionary["CFBundleVersion"] as? String
        //return "\(version ?? "") build \(build ?? "")"
    }
    
    
    
}

