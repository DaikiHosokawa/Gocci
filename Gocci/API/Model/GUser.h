//
//  GUser.h
//  Gocci
//
//  Created by ArzenalZkull on 3/13/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GUser : NSObject

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *pwd;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *avatarLink;

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary;
- (void)loadUser;
- (void)saveUser;
-(id)init;

@end
