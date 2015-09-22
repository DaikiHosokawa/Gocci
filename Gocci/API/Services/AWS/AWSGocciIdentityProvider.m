//
//  AWSGocciDeveloperAuthenticatedIdentityProvider.m
//  Gocci
//
//  Created by Markus Wanke on 16.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#import <AWSCore/AWSCore.h>
#import "AWSGocciIdentityProvider.h"
#import "const.h"


@interface AWSGocciIdentityProvider()
@property (strong, atomic) NSString *providerName;
@property (strong, atomic) NSString *token;
@property (strong, atomic) NSString *userID;

@end

@implementation AWSGocciIdentityProvider
@synthesize providerName=_providerName;
@synthesize token=_token;


- (instancetype)initWithRegionType:(AWSRegionType)regionType
                    identityPoolID:(NSString *)identityPoolID
                        identityID:(NSString *)identityID
                            userID:(NSString *)userID
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName
                         initToken:(NSString *)token
{
    if (self = [super initWithRegionType:regionType identityId:identityID accountId:nil identityPoolId:identityPoolID logins:logins]) {
        self.providerName = providerName;
        self.token = token;
        self.userID = userID;
    }
    return self;
}

/*
 * TODO XXX Use the refresh method to communicate with your backend to get an
 * identityId and token.
 */

- (AWSTask *)refresh {
    /*
     * Get the identityId and token by making a call to your backend
     */
    // Call to your backend
    
    // Set the identity id and token
//    self.identityId = response.identityId;
//    self.token = response.token;
    [super refresh];
    return [AWSTask taskWithResult:self.identityId];
}

/*
 * If the app has a valid identityId return it, otherwise get a valid
 * identityId from your backend.
 */
- (AWSTask *)getIdentityId {
    // already cached the identity id, return it
//    if (self.identityId) {
//        return [AWSTask taskWithResult:nil];
//    }
    // otherwise call your backend to get identityId
    return [AWSTask taskWithResult:self.identityId];
}

@end
/*
// ========================================================================


@interface AWSGocciIdentityProvider()
@property (strong, atomic) NSString *providerName;
@property (strong, atomic) NSString *token;
@end

@implementation AWSGocciIdentityProvider
@synthesize providerName=_providerName;
@synthesize token=_token;


- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName
                      initialToken:(NSString*)initToken
{
    if (self = [super initWithRegionType:regionType identityId:identityId accountId:nil identityPoolId:identityPoolId logins:logins]) {
        self.providerName = providerName;
        self.token = initToken;
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
        return [AWSTask taskWithResult:self.identityId];
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
    return [super refresh];
//    if (![self authenticatedWithProvider]) {
//        // We're using the simplified flow, so just return identity id
//        return [super getIdentityId];
//    }
//    else {
////        return [[self.client getToken:self.identityId logins:self.logins] continueWithSuccessBlock:^id(AWSTask *task) {
////            if (task.result) {
////                DeveloperAuthenticationResponse *response = task.result;
////                if (![self.identityPoolId isEqualToString:response.identityPoolId]) {
////                    return [AWSTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
////                                                                     code:DeveloperAuthenticationClientInvalidConfig
////                                                                 userInfo:nil]];
////                }
////                
////                // potential for identity change here
////                self.identityId = response.identityId;
////                self.token = response.token;
////            }
////            return [AWSTask taskWithResult:self.identityId];
////        }];
//        
//        return [[AWSTask taskWithResult:nil] continueWithBlock:^id(AWSTask *task) {
////            if (!self.identityId) {
////                return [self refresh];
////            }
//            return [AWSTask taskWithResult:self.identityId];
//        }];
//    }
}


            
@end
 
 */
