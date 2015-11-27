//
//  Persistent.swift
//  All Userdate will be saved & loaded with this class. Makes it Easy for dummy loads etc.
//
//  Created by Markus Wanke on 27.10.15.
//  Copyright © 2015 Massara. All rights reserved.
//



import Foundation

// Singelton
let Persistent = PersistentDataStorage()

//@objc class PersistentDataStorage: NSObject {
class PersistentDataStorage {
    
    // this will survive app deinstalltion
    let sud = NSUserDefaults(suiteName: "com.inase.gocci")!
    
    var passwordWasSetByTheUser: Bool {
        get { return cache.passwordWasSetByTheUser ?? defaults.passwordWasSetByTheUser }
        set(v) { cache.passwordWasSetByTheUser = v ; sud.setBool(v, forKey: "passwordWasSetByTheUser") }
    }
    
    var userIsConnectedViaFacebook: Bool {
        get { return cache.userIsConnectedViaFacebook ?? defaults.userIsConnectedViaFacebook }
        set(v) { cache.userIsConnectedViaFacebook = v ; sud.setBool(v, forKey: "userIsConnectedViaFacebook") }
    }
    
    var userIsConnectedViaTwitter: Bool {
        get { return cache.userIsConnectedViaTwitter ?? defaults.userIsConnectedViaTwitter }
        set(v) { cache.userIsConnectedViaTwitter = v ; sud.setBool(v, forKey: "userIsConnectedViaTwitter") }
    }
    
    var identity_id: String? {
        get { return cache.identity_id }
        set(v) { cache.identity_id = v ; sud.setString(v, forKey: "identity_id") }
    }
    
    var twitter_key: String? {
        get { return cache.twitter_key }
        set(v) { cache.twitter_key = v ; sud.setString(v, forKey: "twitter_key") }
    }
    
    var twitter_secret: String? {
        get { return cache.twitter_secret }
        set(v) { cache.twitter_secret = v ; sud.setString(v, forKey: "twitter_secret") }
    }
    
    var facebook_token: String? {
        get { return cache.facebook_token }
        set(v) { cache.facebook_token = v ; sud.setString(v, forKey: "facebook_token") }
    }
    
    func reloadAllDataFromDisk() {
        cache.passwordWasSetByTheUser = sud.boolForKey("passwordWasSetByTheUser")
        cache.userIsConnectedViaFacebook = sud.boolForKey("userIsConnectedViaFacebook")
        cache.userIsConnectedViaTwitter = sud.boolForKey("userIsConnectedViaTwitter")
        cache.identity_id = sud.stringForKey("identity_id")
        cache.twitter_key = sud.stringForKey("twitter_key")
        cache.twitter_secret = sud.stringForKey("twitter_secret")
        cache.facebook_token = sud.stringForKey("facebook_token")
    }
    
    
    struct InternalCache {
        var passwordWasSetByTheUser: Bool?
        var userIsConnectedViaFacebook: Bool?
        var userIsConnectedViaTwitter: Bool?
        var identity_id: String?
        var twitter_key: String?
        var twitter_secret: String?
        var facebook_token: String?
    }
    
    struct InternalDefaults {
        let passwordWasSetByTheUser: Bool = false
        let userIsConnectedViaFacebook: Bool = false
        let userIsConnectedViaTwitter: Bool = false
    }
    
    var cache = InternalCache()
    let defaults = InternalDefaults()
    
    init() {
        reloadAllDataFromDisk()
    }
    
    func immediatelySaveToDisk() {
        sud.synchronize()
    }
    
    
    /// You can't continue the application flow after calling this method. You must start with the tutorial again
    /// because there will be no account data stored anymore
    func resetGocciToInitialState() {
        
        let defaultDomain = NSBundle.mainBundle().bundleIdentifier!
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(defaultDomain)
        sud.removePersistentDomainForName(defaultDomain)
        sud.removePersistentDomainForName("com.inase.gocci")
        cache = InternalCache()
    }
    
    func resetGocciButKeepAccount() {
        let iid = self.identity_id
        resetGocciToInitialState()
        self.identity_id = iid
    }
}







