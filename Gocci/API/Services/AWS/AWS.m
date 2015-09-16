//
//  AWS.m
//  Gocci
//
//  Created by Ma Wa on 14.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//



#import "AWS.h"
#import "const.h"

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

//#import "APIClient.h"


@interface AWS (){
    //NSArray *pages;
}


@property (strong, atomic) AWSCognitoCredentialsProvider *credentialsProvider;

@property (strong, atomic) AWSServiceConfiguration *configuration;




@end

static AWS *sharedInstance = nil;

@implementation AWS : NSObject

+ (void)prepareWithIdentityID:(NSString*)iid andDevAuthToken:(NSString*)token
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AWS alloc] initWithIdentityID:iid andDevAuthToken:token];
    });
}


+ (instancetype)sharedInstance
{
    assert(sharedInstance);
    return sharedInstance;
}


- (id)initWithIdentityID:(NSString*)iid andDevAuthToken:(NSString*)token
{
    self = [super init];
    
    if (self) {
#ifdef INDEVEL
        [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
#endif
        
        NSMutableDictionary *logins = [[NSMutableDictionary alloc] init];
        [logins setObject:token forKey:GOCCI_DEV_AUTH_PROVIDER_STRING];
        
        //create credentialProvider
        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION
                                                                                  identityId:iid
                                                                              identityPoolId:COGNITO_POOL_ID
                                                                                      logins:logins];
        
        self.configuration = [[AWSServiceConfiguration alloc] initWithRegion:COGNITO_POOL_REGION
                                                         credentialsProvider:self.credentialsProvider];
        
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = self.configuration;
        
        NSLog(@"AWS Layer: Setup complete for identity_id: %@", self.credentialsProvider.identityId);
        NSLog(@"AWS Layer: Current credentials will expire at: %@", self.credentialsProvider.expiration);
        
        [self refresh];
        
        
    }
    
    return self;
}

- (void)addLoginAuthenticationProvider:(NSString*)provider authToken:(NSString*)token
{
    [self.credentialsProvider.logins setValue:token forKey:provider];
    [self refresh];
}

- (void)refresh {
    
    //refresh Cognito
    [[self.credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
        NSLog(@"AWS Layer: REFRESHED! Will expire at: %@", self.credentialsProvider.expiration);
        return nil;
    }];
}


@end




