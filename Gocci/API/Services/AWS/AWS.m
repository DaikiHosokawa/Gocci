//
//  AWS.m
//  Gocci
//
//  Created by Markus Wanke on 14.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//



#import "AWS.h"
#import "const.h"

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

#import "AWSGocciIdentityProvider.h"

//#import "APIClient.h"


@interface AWS (){
    //NSArray *pages;
}


@property (strong, atomic) AWSCognitoCredentialsProvider *credentialsProvider;

@property (strong, atomic) AWSServiceConfiguration *configuration;

@property (strong, atomic) AWSGocciIdentityProvider *identityProvider;


@end

static AWS *sharedInstance = nil;

static dispatch_once_t onceToken;


@implementation AWS : NSObject

+ (void)prepare
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AWS alloc] init];
    });
}

+ (void)prepareWithSNSProvider:(NSString*)provider SNStoken:(NSString*)token
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AWS alloc] initWithSNSProvider:provider SNSToken:token];
    });
}

+ (void)prepareWithIdentityID:(NSString*)iid userID:(NSString*)userID devAuthToken:(NSString*)token
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AWS alloc] initWithIdentityID:iid userID:userID devAuthToken:token];
    });
}


+ (instancetype)sharedInstance
{
    assert(sharedInstance);
    return sharedInstance;
}


- (id)initWithIdentityID:(NSString*)iid userID:(NSString*)userID devAuthToken:(NSString*)token
{
    self = [super init];
    
    if (self) {
#ifdef INDEVEL
        [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
#endif
        
        NSMutableDictionary *logins = [[NSMutableDictionary alloc] init];
        // TODO the token is set in the AWSGocciIdentityProvider from now on, so this should not be nessasary anymore
        [logins setObject:token forKey:GOCCI_DEV_AUTH_PROVIDER_STRING];
        

        self.identityProvider = [[AWSGocciIdentityProvider alloc]
                                 initWithRegionType:COGNITO_POOL_REGION
                                 identityPoolID:COGNITO_POOL_ID
                                 identityID:iid
                                 userID:userID
                                 logins:logins
                                 providerName:GOCCI_DEV_AUTH_PROVIDER_STRING
                                 initToken:token];
                                 
        
        
        //create credentialProvider
        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                    initWithRegionType:COGNITO_POOL_REGION
                                    identityProvider:self.identityProvider
                                    unauthRoleArn:nil authRoleArn:nil];
        
        
        //create credentialProvider
//        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION
//                                                                                  identityId:iid
//                                                                              identityPoolId:COGNITO_POOL_ID
//                                                                                      logins:logins];
        
        self.configuration = [[AWSServiceConfiguration alloc] initWithRegion:COGNITO_POOL_REGION
                                                         credentialsProvider:self.credentialsProvider];
        
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = self.configuration;
        
        NSLog(@"AWS Layer: Setup complete for identity_id: %@", self.credentialsProvider.identityId);
        NSLog(@"AWS Layer: Current credentials will expire at: %@", self.credentialsProvider.expiration);
        
        [self refresh];
        
        
    }
    
    return self;
}

+ (NSString*)getIIDforRegisterdSNSProvider:(NSString*)provider SNSToken:(NSString*)token
{
#ifdef INDEVEL
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
#endif
    
    NSMutableDictionary *logins = [[NSMutableDictionary alloc] init];
    [logins setObject:token forKey:provider];
    
    AWSCognitoCredentialsProvider *cp = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION identityId:nil identityPoolId:COGNITO_POOL_ID logins:logins];
    
    //        [self.credentialsProvider clearCredentials];
    //        [self.credentialsProvider clearKeychain];
    
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:COGNITO_POOL_REGION credentialsProvider:cp];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [[cp getIdentityId] waitUntilFinished];
    
    NSString* iid = cp.identityId;
    
    NSLog(@"=== AWS SNS identity_id: %@", iid);
    NSLog(@"=== AWS SNS current credentials will expire in %f hours.", [cp.expiration timeIntervalSinceDate:[[NSDate alloc] init]] / 60 / 60);
    
    
    return iid;
}

- (id)initWithSNSProvider:(NSString*)provider SNSToken:(NSString*)token
{
    self = [super init];
    
    if (self) {
#ifdef INDEVEL
        [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
#endif
        
        NSMutableDictionary *logins = [[NSMutableDictionary alloc] init];
        [logins setObject:token forKey:provider];

        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION identityId:nil identityPoolId:COGNITO_POOL_ID logins:logins];
        
//        [self.credentialsProvider clearCredentials];
//        [self.credentialsProvider clearKeychain];
        
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:COGNITO_POOL_REGION credentialsProvider:self.credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
        

        NSLog(@"=== AWS Layer: Setup complete for identity_id: %@", [self.credentialsProvider getIdentityId]);
        NSLog(@"=== AWS Layer: Current credentials will expire in %f hours.", [self.credentialsProvider.expiration timeIntervalSinceDate:[[NSDate alloc] init]] / 60 / 60);
        
        
        
 
    }
    
    return self;

}

- (id)init
{
    self = [super init];
    
    if (self) {
#ifdef INDEVEL
        [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
#endif
        
        NSMutableDictionary *logins = [[NSMutableDictionary alloc] init];
        
        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION identityId:nil identityPoolId:COGNITO_POOL_ID logins:logins];
        
        //        [self.credentialsProvider clearCredentials];
        //        [self.credentialsProvider clearKeychain];
        
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:COGNITO_POOL_REGION credentialsProvider:self.credentialsProvider];
        
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    }
    
    return self;
    
}


- (NSString*)iid
{
    [[self.credentialsProvider getIdentityId] waitUntilFinished];

    return [self.credentialsProvider getIdentityId].result;
}


- (void)addLoginAuthenticationProvider:(NSString*)provider authToken:(NSString*)token
{
    [self.credentialsProvider.logins setValue:token forKey:provider];
    //[self refresh];
}

- (void)refresh {
    
    //refresh Cognito
    [[self.credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
        NSLog(@"AWS Layer: REFRESHED! Identity ID: %@", [self.credentialsProvider getIdentityId]);
        NSLog(@"AWS Layer: REFRESHED! Will expire at: %@", self.credentialsProvider.expiration);
        
        return nil;
    }];
}


@end




