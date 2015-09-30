//
//  AWSManager.swift
//  Gocci
//
//  Created by Markus Wanke on 28.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation

let AWS2 = AWSManager.sharedInstance

class GocciDevAuthIdentityProvider : AWSAbstractIdentityProvider
{
    
    var backEndToken: String!
    var poolID: String!
    
    override var token: String! {
        return backEndToken
    }
    override var identityPoolId: String! {
        return poolID
    }

    
    //let token: String!
    
    init(poolID: String!, iid:String!, userID:String!, token:String!) {
        
        self.backEndToken = token
        self.poolID = poolID

        super.init()
        super.identityId = iid
        if userID != nil {
            super.logins = [ GOCCI_DEV_AUTH_PROVIDER_STRING: userID]
        }
    }
    
    convenience init(poolID: String!) {
        self.init(poolID: poolID, iid: nil, userID: nil, token: nil)
    }
    
    func connectWithBackEnd(iid:String!, userID:String!, token:String!) {
        self.backEndToken = token
        super.identityId = iid
        super.logins = [ GOCCI_DEV_AUTH_PROVIDER_STRING: userID]
        self.refresh()
    }
    
    override func getIdentityId() -> AWSTask! {
        
        return AWSTask.init(result: self.identityId)

        
//        return [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
//            if (!self.identityId) {
//            return [self refresh];
//            }
//            return [BFTask taskWithResult:self.identityId];
//            }];
    }
    
    override func refresh() -> AWSTask! {
            /*
            * Get the identityId and token by making a call to your backend
            */
            // Call to your backend
            
            // Set the identity id and token
            //    self.identityId = response.identityId;
            //    self.token = response.token;
        super.refresh()
        print("refresh got actually called");
        return AWSTask.init(result: self.identityId)
        
        /*
            // already cached the identity id, return it
            if (self.identityId) {
                return [BFTask taskWithResult:nil];
            }
            // not authenticated with our developer provider
            else if (![self authenticatedWithProvider]) {
                return [super getIdentityId];
            }
            // authenticated with our developer provider, use refresh logic to get id/token pair
            else {
                return [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
                    if (!self.identityId) {
                        return [self refresh];
                    }
                    return [BFTask taskWithResult:self.identityId];
                }];
            }
            */
    }
}

class AWSManager {
    static let sharedInstance = AWSManager(poolID: COGNITO_POOL_ID, cognitoRegion: AWSRegionType.USEast1, S3Region: AWSRegionType.APNortheast1)
    
    let credentialsProvider: AWSCognitoCredentialsProvider
    let identityProvider: GocciDevAuthIdentityProvider
    let unAuthIID: String
    
    init(poolID:String, cognitoRegion:AWSRegionType, S3Region:AWSRegionType) {
        
        identityProvider = GocciDevAuthIdentityProvider(poolID: poolID)

        
        //credentialsProvider = AWSCognitoCredentialsProvider(regionType: cognitoRegion, identityPoolId: poolID)
        
        credentialsProvider = AWSCognitoCredentialsProvider(regionType: cognitoRegion, identityProvider: identityProvider, unauthRoleArn: nil, authRoleArn: nil)

        // config for cognito datasets
        let config1 = AWSServiceConfiguration(region: cognitoRegion, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = config1
        
        // config for S3 uploads (different region!)
        let config2 = AWSServiceConfiguration(region: S3Region, credentialsProvider: credentialsProvider)
        AWSS3TransferUtility.registerS3TransferUtilityWithConfiguration(config2, forKey: "gocci_up_north_east_1")
        
        // if we disable unAuth users one day, 0000.... will be used
        unAuthIID = credentialsProvider.identityId ?? "nowhere:00000000-0000-0000-0000-000000000000"
        print("======= THE UNAUTH IID: \(unAuthIID)")
    }
    
    func successfullyLogedIn() -> Bool {
        return credentialsProvider.identityId != unAuthIID
    }
    
    func connectWithBackend(iid:String, userID:String, token:String) {
        printIID()
        identityProvider.connectWithBackEnd(iid, userID: userID, token: token)
        printIID()
    }
    
    func storeSignUpDataInCognito(username:String) {
        let dataset = AWSCognito.defaultCognito().openOrCreateDataset("signup_data")
        
        if let uid: String = identityProvider.logins?[GOCCI_DEV_AUTH_PROVIDER_STRING] as? String {
            dataset.setString(uid, forKey: "user_id")
        }

        dataset.setString(username, forKey: "username")
        dataset.setString(Util.getRegisterID(), forKey: "register_id")
        dataset.setString(UIDevice.currentDevice().systemName, forKey: "system_name")
        dataset.setString(UIDevice.currentDevice().systemVersion, forKey: "system_version")
        dataset.setString(UIDevice.currentDevice().model, forKey: "model")
        dataset.setString(UIDevice.currentDevice().name, forKey: "other_name")
        dataset.setString(credentialsProvider.identityId, forKey: "first_identity_id")
        
        dataset.synchronize().continueWithBlock { (task) -> AnyObject! in
            print("Uploaded a lot of user data to cognito...")
            return nil
        }
        
    }

//    func addGocciIdentityProvider(giip: AWSAbstractIdentityProvider) {
//        printIID()
//        credentialsProvider.identityProvider = giip
//        printIID()
//        credentialsProvider.refresh()
//        printIID()
//    }
    
    func addSNSProvider(provider: String, token: String) {
        printIID()
        credentialsProvider.logins = [provider: token]
        printIID()
        credentialsProvider.refresh()
        printIID()

    }
    
    func printIID() {
        let currentIID = credentialsProvider.identityId
        credentialsProvider.getIdentityId().waitUntilFinished()
        let retrievedIID = credentialsProvider.identityId
        credentialsProvider.refresh().waitUntilFinished()
        let refreshedIID = credentialsProvider.identityId
        
        print("===================================================================================================")
        print("=== AWS-Manager: IID Status")
        print("Current IID  : \(currentIID)")
        print("Retrieved IID: \(retrievedIID)")
        print("Refreshed IID: \(refreshedIID)")
        print("===================================================================================================")

    }
    
    // TODO test if this works
    func getS3uploader() -> AWSS3TransferUtility {
        return AWSS3TransferUtility.S3TransferUtilityForKey("gocci_up_north_east_1")!
    }
    

    
}

