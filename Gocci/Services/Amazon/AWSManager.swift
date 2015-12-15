//
//  AWSManager.swift
//  Gocci
//
//  Created by Markus Wanke on 28.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

import Foundation


let AWS2 = AWSManager.sharedInstance



class AAA : AWSAbstractIdentityProvider
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
    
    func connectWithBackEnd(iid:String!, userID:String!, token:String!){
        self.backEndToken = token
        super.identityId = iid
        super.logins = [ GOCCI_DEV_AUTH_PROVIDER_STRING: userID]
        self.refresh()
    }
    
//    override func getIdentityId() -> AWSTask! {
//        
//        return AWSTask.init(result: self.identityId)
//        
//        
//        //        return [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
//        //            if (!self.identityId) {
//        //            return [self refresh];
//        //            }
//        //            return [BFTask taskWithResult:self.identityId];
//        //            }];
//    }
//    
//    override func refresh() -> AWSTask! {
//        /*
//        * Get the identityId and token by making a call to your backend
//        */
//        // Call to your backend
//        
//        // Set the identity id and token
//        //    self.identityId = response.identityId;
//        //    self.token = response.token;
//        super.refresh()
//        print("refresh got actually called");
//        return AWSTask.init(result: self.identityId)
//        
//        /*
//        // already cached the identity id, return it
//        if (self.identityId) {
//        return [BFTask taskWithResult:nil];
//        }
//        // not authenticated with our developer provider
//        else if (![self authenticatedWithProvider]) {
//        return [super getIdentityId];
//        }
//        // authenticated with our developer provider, use refresh logic to get id/token pair
//        else {
//        return [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
//        if (!self.identityId) {
//        return [self refresh];
//        }
//        return [BFTask taskWithResult:self.identityId];
//        }];
//        }
//        */
//    }
}





class GocciDevAuthIdentityProvider : AWSAbstractCognitoIdentityProvider
{
    var backEndToken: String!
    var backEndProviderString: String!

    
    override var token: String! {
        return backEndToken
    }
    override var providerName: String! {
        return backEndProviderString
    }
    
    init(region:AWSRegionType, poolID: String, iid:String!, logins:[NSObject : AnyObject]!) {
        backEndProviderString = GOCCI_DEV_AUTH_PROVIDER_STRING
        super.init(regionType: region, identityId: iid, accountId: nil, identityPoolId: poolID, logins:logins)
    }
    
    convenience init(region:AWSRegionType, poolID: String!) {
        self.init(region:region, poolID: poolID, iid:nil, logins:nil)
    }
    
    func connectWithSNSProvider(prov:String, token:String) -> AWSTask {
        addLogin(prov, token: token)
        return refresh()
    }
    
    
    func connectWithBackEnd(iid:String!, userID:String!, token:String!) {

        addLogin(GOCCI_DEV_AUTH_PROVIDER_STRING, token: userID) // yes this is correct. userID has to be the token
        //addLogin("cognito-identity.amazonaws.com", token: token)
        backEndToken = token
        identityId = iid
        
        super.refresh().waitUntilFinished()
        //return refresh()
    }
    
    func addLogin(provider:String, token:String) {
        if logins != nil {
            logins[provider] = token
        }
        else {
            logins = [provider: token]
        }
    }
    
//    override func getIdentityId() -> AWSTask! {
//        
//        return AWSTask.init(result: self.identityId)
//        
//    }
//    
    override func refresh() -> AWSTask! {
        print("refresh got actually called");
        
        
        return super.refresh()
        

    }
}




class EnhancedGocciIdentityProvider : AWSAbstractIdentityProvider
{
    
    var backEndToken: String!
    var poolID: String!
    
    override var token: String! {
        return backEndToken
    }
    override var identityPoolId: String! {
        return poolID
    }
    
    
    init(poolID: String!, iid:String!, userID:String!, token:String!) {
        
        self.backEndToken = token
        self.poolID = poolID
        
        super.init()
        super.identityId = iid
        if userID != nil {
        super.logins = [ GOCCI_DEV_AUTH_PROVIDER_STRING: userID]
        }
    }
    
    func connectWithBackEnd(iid:String!, userID:String!, token:String!){
        self.backEndToken = token
        super.identityId = iid
        super.logins = [ GOCCI_DEV_AUTH_PROVIDER_STRING: userID]
    }
}




class SNSIIDRetrieverIdentityProvider : AWSAbstractCognitoIdentityProvider
{
    init(region:AWSRegionType, poolID: String, iid:String!, logins:[NSObject : AnyObject]!) {
        super.init(regionType: region, identityId: iid, accountId: nil, identityPoolId: poolID, logins:logins)
    }
}


class AWSManager {
    static let sharedInstance = AWSManager(poolID: COGNITO_POOL_ID, cognitoRegion: AWSRegionType.USEast1, S3Region: AWSRegionType.APNortheast1)
    
    let credentialsProvider: AWSCognitoCredentialsProvider
    
    init(poolID:String, cognitoRegion:AWSRegionType, S3Region:AWSRegionType) {

//        AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose
        
        let ip = EnhancedGocciIdentityProvider(poolID: poolID, iid: nil, userID: nil, token: nil)

        credentialsProvider = AWSCognitoCredentialsProvider(regionType: cognitoRegion, identityProvider: ip, unauthRoleArn: nil, authRoleArn: nil)
        
        // config for cognito datasets
        let config1 = AWSServiceConfiguration(region: cognitoRegion, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = config1
        
        // config for S3 uploads (different region!)
        let config2 = AWSServiceConfiguration(region: S3Region, credentialsProvider: credentialsProvider)
        AWSS3TransferUtility.registerS3TransferUtilityWithConfiguration(config2, forKey: "gocci_up_north_east_1")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "identityDidChange:",
            name: AWSCognitoIdentityIdChangedNotification, object: nil)
    }
    
    
    @objc func identityDidChange(not:NSNotification) {
        
        if let ud = not.userInfo as? Dictionary<String,String> {
            let old = ud[AWSCognitoNotificationPreviousId] ?? "Notification Fail"
            let new = ud[AWSCognitoNotificationNewId] ?? "Notification Fail"
            
            print("===================================================================================================")
            print("===================================================================================================")
            print("=== IDENTITY ID CHANGED FROM: \(old)")
            print("                          TO: \(new)")
            print("===================================================================================================")
            print("===================================================================================================")
        }
    }
    
    

    

    
//    func successfullyLogedIn() -> Bool {
//        return credentialsProvider.identityId != unAuthIID
//    }
    
    func refresh() -> AWSTask {
        return credentialsProvider.refresh()
    }
    
    func connectWithBackend(iid:String, userID:String, token:String, and: Bool->()) {

        // TODO there is no verification that the backend login worked. The only sane check that I know of is upload somethin in a dataset, redownload it
        // and compare. There must be a better method, but AWS is a huge pile of shit and nowhere do they even consider that their server could be down.
        (credentialsProvider.identityProvider as! EnhancedGocciIdentityProvider).connectWithBackEnd(iid, userID: userID, token: token)
        credentialsProvider.refresh().continueWithBlock { (task) -> AnyObject! in
            
            Util.runOnMainThread {
            // TODO make a proper login success check if you know how...
                if let e = task.error {
                    Lo.error("AWS2: \(e)")
                    and(false)
                }
                else if let e = task.exception {
                    Lo.error("AWS2: \(e)")
                    and(false)
                }
                else {
                    and(true)
                }
            }
            
            return nil
        }
    }
    

    
//    func connectWithSNSProvider(provider: String, token: String) -> AWSTask {
//
//        print("=== Logins before IP: \(identityProvider.logins)")
//        let d = identityProvider.connectWithSNSProvider(provider, token:token)
//        print("=== Logins before IP: \(identityProvider.logins)")
//        return refresh()
//    }
    
    func storeSignUpDataInCognito(username:String) {
        let dataset = AWSCognito.defaultCognito().openOrCreateDataset("signup_data")

        dataset.setString(Persistent.user_id ?? "user_id not set", forKey: "user_id")
        dataset.setString(Persistent.user_name ?? "username not set", forKey: "username")
        dataset.setString(Persistent.device_token ?? "no device_token", forKey: "device_token")
        dataset.setString(UIDevice.currentDevice().systemName, forKey: "system_name")
        dataset.setString(UIDevice.currentDevice().systemVersion, forKey: "system_version")
        dataset.setString(UIDevice.currentDevice().model, forKey: "model")
        dataset.setString(UIDevice.currentDevice().name, forKey: "name")
        dataset.setString(credentialsProvider.identityId, forKey: "first_identity_id")
        
        dataset.synchronize()
    }

    
    func storeTimeInLoginDataSet() {
        let dataset = AWSCognito.defaultCognito().openOrCreateDataset("login_data")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd  H:mm"
        
        dataset.setString(dateFormatter.stringFromDate(NSDate()), forKey: "time")
        
        dataset.synchronize()
    }
    
    func storeSNSTokenInDataSet(provider:String, token:String) {
        let dataset = AWSCognito.defaultCognito().openOrCreateDataset("sns_tokens")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd  H:mm"
        
        dataset.setString(token, forKey: provider)
        
        dataset.synchronize()
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
    
    
    
    func getIIDforSNSLogin(provider:String, token:String) -> AWSTask{
        
        let ip = SNSIIDRetrieverIdentityProvider(region: AWSRegionType.USEast1, poolID: COGNITO_POOL_ID, iid: nil, logins: [provider:token])
        
        return ip.refresh().continueWithBlock({ (task) -> AnyObject! in
            return AWSTask.init(result: ip.identityId == nil ? nil : ip.identityId)
        })
    }
    
    func loginInWithProviderToken(provider: String, token: String,
        onNotRegisterdSNS: ()->(),
        onNotRegisterdIID:()->(),
        onUnknownError: ()->(),
        onSuccess: ()->())
    {
        getIIDforSNSLogin(provider, token: token).continueWithBlock { task -> AnyObject! in
            
            if task.result == nil {
                onNotRegisterdSNS()
                return nil
            }
            
            Persistent.identity_id = task.result as! String
            
            APIHighLevel.nonInteractiveLogin(
                onIIDNotAvailible:  onNotRegisterdIID,
                onNetworkFailure:   nil, // will show popup default
                onAPIFailure:       onUnknownError,
                onAWSFailure:       nil, // not needed until video upload, where an auto retry happens
                onSuccess:          onSuccess)
            
            return nil
        }
    }
    
    func uploadVideoToMovieBucket(vdeoFileURL: NSURL, filename: String) {
        
        let completionHandler: (AWSS3TransferUtilityUploadTask!, NSError?) -> () = { task, error in
            if error != nil {
                print("=============== ERROR: FROM THE COMPLETION HANDLER! : \(error)")
            }
            else {
                print("=============== SUCCESS, upload completet.")
                Util.popup("Upload to S3 complete.")
            }
        }
        
        
        let tu = AWSS3TransferUtility.S3TransferUtilityForKey("gocci_up_north_east_1")!
        
        let uploadTask = tu.uploadFile(vdeoFileURL,
            bucket: AWS_S3_VIDEO_UPLOAD_BUCKET,
            key: filename,
            contentType: "video/quicktime",
            expression: nil,
            completionHander: completionHandler)
            
        uploadTask.continueWithBlock{ task in
            if task.error != nil {
                print("=============== ERROR: ", task.error)
            }
            else if task.exception != nil {
                print("=============== ERROR: ", task.exception)
            }
            else {
                print("=============== MAYBE upload success. At least no error in the continue Task block")
            }
            
            return nil
        }
    }
}

