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
#define NETOP_SUCCESS 0
#define NETOP_NETWORK_ERROR 1
#define NETOP_IDENTIFY_ID_NOT_REGISTERD 2


@interface NetOp : NSObject

+ (void)loginWithIID:(NSString *)iid andThen:(void (^)(int errorCode, NSString *errorMsg))afterBlock;

@end


#endif /* NetOp_h */
