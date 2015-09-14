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


@property (strong, nonatomic) AWSCognitoCredentialsProvider *credentialsProvider;

@property (strong, nonatomic) AWSServiceConfiguration *configuration;




@end


@implementation AWS : NSObject


+ (instancetype)sharedInstance {
    
    static AWS *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AWS alloc] init];
    });
    return sharedInstance;
}


- (id)init {
    
    self = [super init];
    
    if (self) {
        //create credentialProvider
        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION
                                                                              identityPoolId:COGNITO_POOL_ID];
                                    
        self.configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:self.credentialsProvider];
        
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = self.configuration;
    }
    
    return self;
}

- (void)refresh {
    // TODO do not use userdefs for token
    // TODO warning, this overwrites other logins like facebook? dict merge?
    //unique provider insert
    self.credentialsProvider.logins = @{ GOCCI_DEV_AUTH_PROVIDER_STRING: [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
    
    //refresh Cognito
    [[self.credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
        // Your handler code heredentialsProvider.identityId;
        NSLog(@"logins: %@", self.credentialsProvider.logins);
        NSLog(@"task:%@",task);
        // return [self refresh];
        return nil;
    }];
}


@end




