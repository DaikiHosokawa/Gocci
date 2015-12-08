//
//  Persistent.swift
//  All Userdate will be saved & loaded with this class. Makes it Easy for dummy loads etc.
//
//  Created by Markus Wanke on 27.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//



import Foundation

// Singelton
//let Persistent = PersistentDataStorage()

@objc class Persistent: NSObject {
    
    
    class func setupAndCacheAllDataFromDisk() {
        // this will survive app deinstalltion
        KeychainWrapper.serviceName = "com.inase.gocci"
        
        cache.password_was_set_by_the_user = boolForKey("password_was_set_by_the_user")
        cache.user_registerd_for_push_messages = boolForKey("user_registerd_for_push_messages")
        cache.user_is_connected_via_facebook = boolForKey("user_is_connected_via_facebook")
        cache.user_is_connected_via_twitter = boolForKey("user_is_connected_via_twitter")
        
        cache.identity_id = stringForKey("identity_id")
        cache.cognito_token = stringForKey("cognito_token")
        cache.device_token = stringForKey("device_token")
        cache.twitter_key = stringForKey("twitter_key")
        cache.twitter_secret = stringForKey("twitter_secret")
        cache.facebook_token = stringForKey("facebook_token")
        cache.facebook_id = stringForKey("facebook_id")
        
        cache.user_id = stringForKey("user_id")
        cache.user_name = stringForKey("user_name")
        cache.user_profile_image_url = stringForKey("user_profile_image_url")
        
    }
    
    struct InternalCache {
        var password_was_set_by_the_user: Bool?
        var user_registerd_for_push_messages: Bool?
        var user_is_connected_via_facebook: Bool?
        var user_is_connected_via_twitter: Bool?
        
        var identity_id: String?
        var cognito_token: String?
        var device_token: String?
        var twitter_key: String?
        var twitter_secret: String?
        var facebook_token: String?
        var facebook_id: String?
        
        var user_id: String?
        var user_name: String?
        var user_profile_image_url: String?
    }
    
    struct InternalDefaults {
        let password_was_set_by_the_user: Bool = false
        let user_registerd_for_push_messages: Bool = false
        let user_is_connected_via_facebook: Bool = false
        let user_is_connected_via_twitter: Bool = false
    }
    
    class var password_was_set_by_the_user: Bool {
        get { return cache.password_was_set_by_the_user ?? defaults.password_was_set_by_the_user }
        set(v) { cache.password_was_set_by_the_user = v ; setBool(v, forKey: "password_was_set_by_the_user") }
    }
    
    class var user_registerd_for_push_messages: Bool {
        get { return cache.user_registerd_for_push_messages ?? defaults.user_registerd_for_push_messages }
        set(v) { cache.user_registerd_for_push_messages = v ; setBool(v, forKey: "user_registerd_for_push_messages") }
    }
    
    class var user_is_connected_via_facebook: Bool {
        get { return cache.user_is_connected_via_facebook ?? defaults.user_is_connected_via_facebook }
        set(v) { cache.user_is_connected_via_facebook = v ; setBool(v, forKey: "user_is_connected_via_facebook") }
    }
    
    class var user_is_connected_via_twitter: Bool {
        get { return cache.user_is_connected_via_twitter ?? defaults.user_is_connected_via_twitter }
        set(v) { cache.user_is_connected_via_twitter = v ; setBool(v, forKey: "user_is_connected_via_twitter") }
    }
    
    class var identity_id: String? {
        get { return cache.identity_id }
        set(v) { cache.identity_id = v ; setString(v!, forKey: "identity_id") }
    }
    
    class var cognito_token: String? {
        get { return cache.cognito_token }
        set(v) { cache.cognito_token = v ; setString(v!, forKey: "cognito_token") }
    }
    
    class var device_token: String? {
        get { return cache.device_token }
        set(v) { cache.device_token = v ; setString(v!, forKey: "device_token") }
    }
    
    class var twitter_key: String? {
        get { return cache.twitter_key }
        set(v) { cache.twitter_key = v ; setString(v!, forKey: "twitter_key") }
    }
    
    class var twitter_secret: String? {
        get { return cache.twitter_secret }
        set(v) { cache.twitter_secret = v ; setString(v!, forKey: "twitter_secret") }
    }
    
    class var facebook_token: String? {
        get { return cache.facebook_token }
        set(v) { cache.facebook_token = v ; setString(v!, forKey: "facebook_token") }
    }
    
    class var facebook_id: String? {
        get { return cache.facebook_id }
        set(v) { cache.facebook_id = v ; setString(v!, forKey: "facebook_id") }
    }
    
    class var user_id: String? {
        get { return cache.user_id }
        set(v) { cache.user_id = v ; setString(v!, forKey: "user_id") }
    }
    
    class var user_name: String? {
        get { return cache.user_name }
        set(v) { cache.user_name = v ; setString(v!, forKey: "user_name") }
    }
 
    class var user_profile_image_url: String? {
        get { return cache.user_profile_image_url }
        set(v) { cache.user_profile_image_url = v ; setString(v!, forKey: "user_profile_image_url") }
    }

    
    private class func setBool(value: Bool, forKey key: String) {
        KeychainWrapper.setObject(value, forKey: key)
    }
    
    private class func setString(value: String, forKey key: String) {
        KeychainWrapper.setString(value, forKey: key)
    }
    
    private class func boolForKey(key: String) -> Bool? {
        return KeychainWrapper.objectForKey(key) as? Bool
    }
    
    private class func stringForKey(key: String) -> String? {
        return KeychainWrapper.stringForKey(key)
    }
    

    
    private static var cache = InternalCache()
    private static let defaults = InternalDefaults()

    
    /// You can't continue the application flow after calling this method. You must start with the tutorial again
    /// because there will be no account data stored anymore
    class func resetPersistentDataToInitialState() {
        
        KeychainWrapper.removeObjectForKey("password_was_set_by_the_user")
        KeychainWrapper.removeObjectForKey("user_registerd_for_push_messages")
        KeychainWrapper.removeObjectForKey("user_is_connected_via_facebook")
        KeychainWrapper.removeObjectForKey("user_is_connected_via_twitter")
        
        KeychainWrapper.removeObjectForKey("identity_id")
        KeychainWrapper.removeObjectForKey("cognito_token")
        KeychainWrapper.removeObjectForKey("device_token")
        KeychainWrapper.removeObjectForKey("twitter_key")
        KeychainWrapper.removeObjectForKey("twitter_secret")
        KeychainWrapper.removeObjectForKey("facebook_token")
        KeychainWrapper.removeObjectForKey("facebook_id")
        
        KeychainWrapper.removeObjectForKey("user_id")
        KeychainWrapper.removeObjectForKey("user_name")
        KeychainWrapper.removeObjectForKey("user_profile_image_url")
        
        
        // TODO delete other stuff as well
        // - scheduler task file
        // - avatar
        cache = InternalCache()
    }
}







