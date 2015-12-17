//
//  Permission.swift
//  Gocci
//
//  Created by Ma Wa on 16.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation
import UIKit



@objc class Permission: NSObject, Logable {
    
    static var verbose = true

    static let logColor: (r: UInt8, g: UInt8, b: UInt8) = (0x99, 0x66, 0xFF)

    static var userChoiceCallBack: (Bool->())? = nil

    class func didRegisterUserNotificationSettings(notificationSettings: UIUserNotificationSettings) {
        
        if notificationSettings.types == UIUserNotificationType.None {
            log("we did not get push message permission from the user")
            Util.runOnMainThread { userChoiceCallBack?(false) }
        }
        else {
            log("the user allowed these notifications: \(notificationSettings.types)")
            UIApplication.sharedApplication().registerForRemoteNotifications()
            Util.runOnMainThread { userChoiceCallBack?(true) }
        }
    }

    class func showThePopupForPushNoticationsOnce(from: UIViewController, after: OVF) {
        
        if !Persistent.do_not_ask_again_for_push_messages {
            
            let pop = RequestPushMessagesPopup(from: from, title: "通知の許可", widthRatio: 80, heightRatio: 30)
            pop.onDecline = { Persistent.do_not_ask_again_for_push_messages = true }
            pop.onAllow =   {
                Persistent.do_not_ask_again_for_push_messages = true
                Permission.showTheHolyPopupForPushNotificationsOrTheSettingsScreen()
            }
            pop.inAnyCase = after
            pop.pop()
        }
        else {
            after?()
        }
    }
    
    class func theHolyPopup(cb: (Bool->())? = nil) {
        // will show the popup only once!!
        Persistent.push_notifications_popup_has_been_shown = true
        userChoiceCallBack = cb
        let app = UIApplication.sharedApplication()
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        app.registerUserNotificationSettings(settings)
    }
    
    class func showTheHolyPopupForPushNotificationsOrTheSettingsScreen() {
        
        if !Persistent.push_notifications_popup_has_been_shown {
            theHolyPopup()
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            // lets hope registerUserNotificationSettings is called per appdid become active
        }
    }
    

//    class func letTheUserConfigureHisPushNotifications() {
//        
//        if Persistent.user_wants_push_notifications == nil {
//            showTheHolyPopupForPushNotifications()
//        }
//        else {
//            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString))
//        }
//    }
//    
    
    class func userHasGrantedPushNotificationPermission() -> Bool {
        guard let currentSettings = UIApplication.sharedApplication().currentUserNotificationSettings() else {
            return false
        }
        
        return currentSettings.types != UIUserNotificationType.None
    }
    
    class func requestPushNotificationPermissionOnlyIfTheUserWantsThem() {
        
        if userHasGrantedPushNotificationPermission() { // && Persistent.user_wants_push_notifications {
            let app = UIApplication.sharedApplication()
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            app.registerUserNotificationSettings(settings)
        }
    }
    
    class func deviceTokenRecived(deviceToken: String?) {
        
        guard var deviceToken = deviceToken else {
            Lo.error("device token was nil")
            return
        }
        
        deviceToken = deviceToken.replace("<", withString: "")
        deviceToken = deviceToken.replace(">", withString: "")
        deviceToken = deviceToken.replace(" ", withString: "")
        
        sep("PERMISSION")
        log("Device Token Recived: \(deviceToken)")
        
        
        if Persistent.registerd_device_token == nil || deviceToken != Persistent.registerd_device_token! {
            log("THIS TOKEN IS NEW!!! Will register for push msgs with a bg task right away!!")
            RegisterForPushMessagesTask(deviceToken: deviceToken).schedule()
        }
        else {
            log("This token is already registed with the server")
        }
        
    }
}






