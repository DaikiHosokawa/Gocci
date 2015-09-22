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

    
    class func setBadgeNumber(numberOfNewMessages: Int) {
    
        // TODO I don't see a reason this has to got to user defaults, however it is read in over 20 places from ud,
        // so this will be fixed in the next version of gocci
        NSUserDefaults.standardUserDefaults().setInteger(numberOfNewMessages, forKey: "numberOfNewMessages")
        
        if numberOfNewMessages > 0 {
            UIApplication.sharedApplication().applicationIconBadgeNumber = numberOfNewMessages
        }
    }
    
    class func randomUsername() -> String
    {
        let s1 = NSProcessInfo.processInfo().globallyUniqueString.characters.filter(){$0 != "-"}
        
        return String(s1[0..<5])
    }

    
    class func generateFakeDeviceID() -> String
    {
        // very cool language
        let s1 = NSProcessInfo.processInfo().globallyUniqueString.characters.filter(){$0 != "-"}
        let s2 = NSProcessInfo.processInfo().globallyUniqueString.characters.filter(){$0 != "-"}
        
        return String(s1[0..<32] + s2[0..<32])
    }
    
    class func getRegisterID() -> String {
        
        let regid = NSUserDefaults.standardUserDefaults().stringForKey("register_id")
        
// Only Fake IDs in the simulator
#if arch(i386) || arch(x86_64)
        return regid ?? generateFakeDeviceID()
#else
        return regid ?? "CANT_DETERMINE_DEVICE_ID"
#endif
    }

    
    class func removeAccountSpecificDataFromUserDefaults() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user_id")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("profile_img")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("identity_id")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("badge_num")
    }
    


    
}
