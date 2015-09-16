//
//  AWSGocciDeveloperAuthenticatedIdentityProvider.m
//  Gocci
//
//  Created by Markus Wanke on 16.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#import <AWSCore/AWSCore.h>
#import "AWSGocciDeveloperAuthenticatedIdentityProvider.h"




@interface AWSGocciDeveloperAuthenticatedIdentityProvider()
//@property (strong, atomic) NSString *providerName;
//@property (strong, atomic) NSString *token;
@end

@implementation AWSGocciDeveloperAuthenticatedIdentityProvider


- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName
{
    if (self = [super initWithRegionType:regionType identityId:identityId accountId:nil identityPoolId:identityPoolId logins:logins]) {
        self.providerName = providerName;
    }
    return self;
}

- (BOOL)authenticatedWithProvider
{
    return [self.logins objectForKey:self.providerName] != nil;
}


- (AWSTask *)getIdentityId
{
    // already cached the identity id, return it
    if (self.identityId) {
        return [AWSTask taskWithResult:nil];
    }
    // not authenticated with our developer provider
    else if (![self authenticatedWithProvider]) {
        return [super getIdentityId];
    }
    // authenticated with our developer provider, use refresh logic to get id/token pair
    else {
        return [[AWSTask taskWithResult:nil] continueWithBlock:^id(AWSTask *task) {
            if (!self.identityId) {
                return [self refresh];
            }
            return [AWSTask taskWithResult:self.identityId];
        }];
    }
}

- (AWSTask *)refresh {
    if (![self authenticatedWithProvider]) {
        // We're using the simplified flow, so just return identity id
        return [super getIdentityId];
    }
    else {
        return [[self.client getToken:self.identityId logins:self.logins] continueWithSuccessBlock:^id(AWSTask *task) {
            if (task.result) {
                DeveloperAuthenticationResponse *response = task.result;
                if (![self.identityPoolId isEqualToString:response.identityPoolId]) {
                    return [AWSTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                                     code:DeveloperAuthenticationClientInvalidConfig
                                                                 userInfo:nil]];
                }
                
                // potential for identity change here
                self.identityId = response.identityId;
                self.token = response.token;
            }
            return [AWSTask taskWithResult:self.identityId];
        }];
        
        return [[AWSTask taskWithResult:nil] continueWithBlock:^id(AWSTask *task) {
            if (!self.identityId) {
                return [self refresh];
            }
            return [AWSTask taskWithResult:self.identityId];
        }];
    }
}


            
@end
