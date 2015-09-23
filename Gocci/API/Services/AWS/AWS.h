//
//  AWS.h
//  Gocci
//
//  Created by Markus Wanke on 14.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#ifndef AWS_h
#define AWS_h


@interface AWS : NSObject

@property (strong, nonatomic) NSString *token;

+ (void)prepare;

+ (void)prepareWithSNSProvider:(NSString*)provider SNStoken:(NSString*)token;

+ (void)prepareWithIdentityID:(NSString*)iid userID:(NSString*)userID devAuthToken:(NSString*)token;


// You must call a prepareWith... function before using this function
+ (instancetype)sharedInstance;

- (void)refresh;

- (void)addLoginAuthenticationProvider:(NSString*)provider authToken:(NSString*)token;

- (NSString*)iid;

@end


#endif /* AWS_h */
