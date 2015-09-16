//
//  AWSGocciDeveloperAuthenticatedIdentityProvider.h
//  Gocci
//
//  Created by Markus Wanke on 16.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#import <AWSCore/AWSIdentityProvider.h>

@interface AWSGocciDeveloperAuthenticatedIdentityProvider : AWSAbstractCognitoIdentityProvider


- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName

@end
