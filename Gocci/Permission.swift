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
    
    class func didFailToRegisterForRemoteNotificationsWithError(error: NSError?) {
        guard let error = error else {
            err("didFailToRegisterForRemoteNotificationsWithError: ERROR is NIL... wtf")
            return
        }
        
        if error.code == 3010 {
            log("WARN Simulator does not support push notifications.")
        }
        else {
            err("\(error)")
        }
    }
    
    class func recievedRemoteNotification(userData: [NSObject: AnyObject]?) {
        sep("RECIEVED REMOTE NOTIFICATION")
        log("\(userData)")
        
        if let data = userData as? [String: AnyObject] {
            
            let noti = NSNotification(name: "Notification", object: nil, userInfo: userData)
            
            NSNotificationQueue.defaultQueue().enqueueNotification(noti, postingStyle: NSPostingStyle.PostWhenIdle) // TODO why?? that for time lines right? why on idle?
            
            // NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            // TODO UNTESTED
            if let frame = data["foreground"] as? [String: AnyObject] {
            
                if let badge = frame["badge"] as? Int {
                    UIApplication.sharedApplication().applicationIconBadgeNumber = badge
                }
                
                if let type = frame["type"] as? String {
                    //Toast.情報("お知らせ", msg, 4.0)
                    
                    switch type {
                        case "comment":
                            handlePushNotificationComment(frame["payload"] as? [String: String] ?? [:])
                            return
                        case "follow":
                            handlePushNotificationFollow(frame["payload"] as? [String: String] ?? [:])
                            return
                        case "like":
                            handlePushNotificationLike(frame["payload"] as? [String: String] ?? [:])
                            return
                        case "announcement":
                            handlePushNotificationAnnouncement(frame["payload"] as? [String: String] ?? [:])
                            return
                        case "post_complete":
                            handlePushNotificationPostComplete(frame["payload"] as? [String: String] ?? [:])
                            return
                        default:
                            break // NO RETURN HERE !!!!  NO CODE AFTER THIS LINE !!! Should fall in that error statment down there
                    }
                }
            }
        }
        
        err("Push Notification has a wrong baseframe. Not parsable.")
    }
    
    
    
    class func handlePushNotificationComment(payload: [String: String]) {
        guard let comment = payload["comment"] else {
            err("handlePushNotificationComment: No comment") ; return
        }
        guard let username = payload["username"] else {
            err("handlePushNotificationComment: No username") ; return
        }
        guard let user_id = payload["user_id"] else {
            err("handlePushNotificationComment: No user_id") ; return
        }
        guard let post_id = payload["post_id"] else {
            err("handlePushNotificationComment: No post_id") ; return
        }
        
        sep("handlePushNotificationComment")
        log("comment: \(comment)")
        log("username: \(username)")
        log("user_id: \(user_id)")
        log("post_id: \(post_id)")
        
        // TODO add action that by click on popup opens the video
        Toast.情報("\(username)さんからコメントされました！", comment, 6.0)
    }
    
    class func handlePushNotificationFollow(payload: [String: String]) {
        guard let username = payload["username"] else {
            err("handlePushNotificationComment: No username") ; return
        }
        guard let user_id = payload["user_id"] else {
            err("handlePushNotificationComment: No user_id") ; return
        }
        
        sep("handlePushNotificationComment")
        log("username: \(username)")
        log("user_id: \(user_id)")
        
        // TODO add action that by click on popup opens the user page
        Toast.情報("お知らせ", "\(username)さんからフォローされました！", 6.0)
    }
    
    class func handlePushNotificationLike(payload: [String: String]) {
        guard let username = payload["username"] else {
            err("handlePushNotificationComment: No username") ; return
        }
        guard let user_id = payload["user_id"] else {
            err("handlePushNotificationComment: No user_id") ; return
        }
        
        sep("handlePushNotificationGocciLike")
        log("username: \(username)")
        log("user_id: \(user_id)")
        
        // TODO add action that by click on popup opens the user page
        Toast.情報("お知らせ", "\(username)さんにゴッチされました！", 6.0)
    }
    
    class func handlePushNotificationAnnouncement(payload: [String: String]) {
        guard let headline = payload["headline"] else {
            err("handlePushNotificationComment: No headline") ; return
        }
        guard let body = payload["body"] else {
            err("handlePushNotificationComment: No body") ; return
        }
        
        sep("handlePushNotificationAnnouncement")
        log("headline: \(headline)")
        log("body: \(body)")
        
        let pop = Util.overlayPopup(headline, body)
        pop.addButton("OK", style: UIAlertActionStyle.Cancel) {  }
        pop.overlay()
    }
    
    class func handlePushNotificationPostComplete(payload: [String: String]) {
        guard let post_id = payload["post_id"] else {
            err("handlePushNotificationComment: No post_id") ; return
        }
        guard let rest_id = payload["rest_id"] else {
            err("handlePushNotificationComment: No rest_id") ; return
        }
        guard let restname = payload["restname"] else {
            err("handlePushNotificationComment: No restname") ; return
        }
        
        sep("handlePushNotificationComment")
        log("post_id: \(post_id)")
        log("rest_id: \(rest_id)")
        log("restname: \(restname)")
        
        // TODO add action that by click on popup opens the video
        Toast.情報("お知らせ", "投稿が完了しました！（\(restname)）", 6.0)
    }
    
    

    class func didRegisterUserNotificationSettings(notificationSettings: UIUserNotificationSettings) {
        
        if notificationSettings.types == UIUserNotificationType.None {
            sep("PUSH MESSAGES")
            log("We did not get push message permission from the user. This is normal on the first start. Should change after posting the first video.")
            Util.runOnMainThread { userChoiceCallBack?(false) }
        }
        else {
            sep("PUSH MESSAGES")
            log("We are now listening for push notifications....")
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






