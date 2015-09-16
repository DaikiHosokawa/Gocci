//
//  NetOp.h
//  Gocci
//
//  Created by Markus Wanke on 11.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#ifndef NetOp_h
#define NetOp_h


// Dirty implementation of error codes, which will be done right in API version 3


typedef NS_ENUM(NSInteger, NetOpResult)
{
    NETOP_SUCCESS = 0,
    NETOP_NETWORK_ERROR,
    NETOP_IDENTIFY_ID_NOT_REGISTERD,
    NETOP_USERNAME_ALREADY_IN_USE
};



@interface NetOp : NSObject

+ (void)loginWithIID:(NSString *)iid andThen:(void (^)(NetOpResult errorCode, NSString *errorMsg))afterBlock;

+ (void)registerUsername:(NSString *)username andThen:(void (^)(NetOpResult errorCode, NSString *errorMsg))afterBlock;

+ (void)loginWithAPIV2Conversation:(NSString*)username avatar:(NSString*)avatar andThen:(void (^)(NetOpResult errorCode, NSString *errorMsg))afterBlock;



@end


#endif /* NetOp_h */
