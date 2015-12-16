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

    class func showThePopupForPushNoticationsOnce(from: UIViewController? = nil) {
        
        if Persistent.ask_user_again_for_push_messages {
            OverlayWindow.show{ vc, hideAgain in
                
                let pop = RequestPushMessagesPopup(from: vc, title: "通知の許可", widthRatio: 80, heightRatio: 30)
                pop.onDecline = { Persistent.ask_user_again_for_push_messages = false }
                pop.onAllow =   { Permission.showTheHolyPopupForPushNotificationsOrTheSettingsScreen() }
                pop.pop()
            }
        }
    }
    
    class func showTheHolyPopupForPushNotificationsOrTheSettingsScreen(cb: (Bool->())? = nil) {
        
        if !Persistent.push_notifications_popup_has_been_shown {
        // will show the popup only once!!
            Persistent.push_notifications_popup_has_been_shown = true
            userChoiceCallBack = cb
            let app = UIApplication.sharedApplication()
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            app.registerUserNotificationSettings(settings)
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
    
    class func userHasAlreadyRegisterdForNotifications() -> Bool {
        guard let currentSettings = UIApplication.sharedApplication().currentUserNotificationSettings() else {
            return false
        }
        
        return currentSettings.types != UIUserNotificationType.None
    }
    
    class func requestPushNotificationPermissionOnlyIfTheUserWantsThem() {
        
        if userHasAlreadyRegisterdForNotifications() { // && Persistent.user_wants_push_notifications {
            let app = UIApplication.sharedApplication()
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            app.registerUserNotificationSettings(settings)
        }
    }
    
    class func deviceTokenRecived(deviceToken: String?) {
        
        guard let deviceToken = deviceToken else {
            Lo.error("device token was nil")
            return
        }
        
        log("Device Token Recived: \(deviceToken)")
        
        deviceToken.replace("<", withString: "")
        deviceToken.replace(">", withString: "")
        deviceToken.replace("=", withString: "")
        
        
        if (deviceToken != Persistent.device_token) { // && Persistent.user_registerd_for_push_messages) {
            //
        }
        
        Persistent.device_token = deviceToken;
    }
}






