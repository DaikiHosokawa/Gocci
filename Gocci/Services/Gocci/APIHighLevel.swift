//
//  APIHighLevel.swift
//  Gocci
//
//  Created by Ma Wa on 14.12.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


@objc class APIHighLevelOBJC: NSObject {
    
    class func signupAndLogin(username: String, onUsernameAlreadyTaken:()->(), and:Bool->()) {
        
        let req = API3.auth.signup()
        req.parameters.username = username
        
        req.on_ERROR_USERNAME_ALREADY_REGISTERD( { _, _ in onUsernameAlreadyTaken() } )
        
        req.perform { payload in
            Persistent.identity_id = payload.identity_id
            Util.sleep(0.3) // nen no tame ni
            
            APIHighLevel.simpleLogin { res in
                
                Util.runInBackground { AWS2.storeSignUpDataInCognito() }
                and(res)
            }
        }
    }
}



class APIHighLevel {


    class func nonInteractiveLogin(onIIDNotAvailible
        onIIDNotAvailible:(()->())?,
        onNetworkFailure:(()->())?,
        onAPIFailure:(()->())?,
        onAWSFailure:(()->())?,
        onSuccess:(()->())?)
    {
        guard let iid = Persistent.identity_id ?? Util.getUserDefString("identity_id") else {
            Lo.error("APIHighLevel: No identity_id set. Login impossible")
            onIIDNotAvailible?()
            return
        }
        
        let req = API3.auth.login()
        
        req.parameters.identity_id = iid
        
        if onAPIFailure != nil {
            req.onAnyAPIError { onAPIFailure?() }
        }
        
        if onNetworkFailure != nil {
            req.onNetworkTrouble { c, m -> () in
                Lo.error("API Login: \(c): \(m)")
                onNetworkFailure?()
            }
        }
        
        req.perform { (payload) -> () in
            stepTwo(payload) { awsLoginSuccess in
                if awsLoginSuccess {
                    onSuccess?()
                }
                else {
                    Lo.error("API Login: AWS Login Failed")
                    onAWSFailure?()
                }
            }
        }
    }
    
    
    class func simpleLogin(and: Bool->()) {
        
        guard let iid = Persistent.identity_id ?? Util.getUserDefString("identity_id") else {
            Lo.error("APIHighLevel: No identity_id set. Login impossible")
            and(false)
            return
        }
        
        let req = API3.auth.login()
        
        req.parameters.identity_id = iid
        
        req.onAnyAPIError { and(false) }
        
        req.perform { (payload) -> () in
            stepTwo(payload) { awsLoginSuccess in
                // we ignore it even when the AWS login fails because it is only needed in case of video uploads
                if !awsLoginSuccess {
                    Lo.error("APIHighLevel: AWS Login Failed. Video upload will maybe fail. Should not happen. Carry on as if nothing happend.")
                }
                and(true)
            }
        }
    }
    
    class func stepTwo(payload: API3.auth.login.Payload, awsLogin:Bool->()) {
        
        //save user data
        Persistent.user_id = payload.user_id
        Persistent.user_name = payload.username
        Persistent.user_profile_image_url = payload.profile_img
        Persistent.cognito_token = payload.cognito_token
        Persistent.identity_id = payload.identity_id
        
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = payload.badge_num
        
        if APISupport.verbose {
            Lo.green("======================================================================")
            Lo.green("====================== USER LOGIN SUCCESSFUL =========================")
            Lo.green("======================================================================")
            Lo.green("    username    :  \(Persistent.user_name)   ")
            Lo.green("    user id     :  \(Persistent.user_id)   ")
            Lo.green("    identity_id :  \(Persistent.identity_id)   ")
            Lo.green("======================================================================")
        }
        
        AWS2.connectWithBackend(Persistent.identity_id, userID: Persistent.user_id, token: Persistent.cognito_token) { awsLogin($0) }
    }
}




