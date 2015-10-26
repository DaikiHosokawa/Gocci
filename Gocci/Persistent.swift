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
    
    var identity_id: String {
        get { return cache.identity_id ?? defaults.identity_id }
        set(v) { cache.identity_id = v ; sud.setString(v, forKey: "identity_id") }
    }
    
    func reloadAllDataFromDisk() {
        cache.passwordWasSetByTheUser = sud.boolForKey("passwordWasSetByTheUser")
        cache.userIsConnectedViaFacebook = sud.boolForKey("userIsConnectedViaFacebook")
        cache.userIsConnectedViaTwitter = sud.boolForKey("userIsConnectedViaTwitter")
        cache.identity_id = sud.stringForKey("identity_id")
    }
    
    
    struct InternalCache {
        var passwordWasSetByTheUser: Bool?
        var userIsConnectedViaFacebook: Bool?
        var userIsConnectedViaTwitter: Bool?
        var identity_id: String?
    }
    
    struct InternalDefaults {
        let passwordWasSetByTheUser: Bool = false
        let userIsConnectedViaFacebook: Bool = false
        let userIsConnectedViaTwitter: Bool = false
        var identity_id: String = "identity_id is undefined"
    }
    
    var cache = InternalCache()
    let defaults = InternalDefaults()
    
    init() {
        reloadAllDataFromDisk()
    }
    
    func immediatelySaveToDisk() {
        sud.synchronize()
    }
    
    private func storeBool(key: String, val: Bool) {
        sud.setBool(val, forKey: key)
    }
    

    
    /// you can't continue the application flow after calling this method. You must start with the tutorial again
    /// because these will be no account data stored
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







