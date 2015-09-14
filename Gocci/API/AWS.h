//
//  AWS.h
//  Gocci
//
//  Created by Ma Wa on 14.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#ifndef AWS_h
#define AWS_h


@interface AWS : NSObject

@property (strong, nonatomic) NSString *token;


+ (instancetype)sharedInstance;

- (void)refresh;

@end


#endif /* AWS_h */
