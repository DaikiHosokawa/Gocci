//
//  AWSGocciDeveloperAuthenticatedIdentityProvider.h
//  Gocci
//
//  Created by Markus Wanke on 16.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//


@interface AWSGocciIdentityProvider : AWSAbstractCognitoIdentityProvider


- (instancetype)initWithRegionType:(AWSRegionType)regionType
                    identityPoolID:(NSString *)identityPoolID
                        identityID:(NSString *)identityID
                            userID:(NSString *)userID
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName
                         initToken:(NSString *)token;

@end
