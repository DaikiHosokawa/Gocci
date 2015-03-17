//
//  GUser.m
//  Gocci
//
//  Created by ArzenalZkull on 3/13/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#import "GUser.h"

@implementation GUser
-(id)init {
    self = [super init];
    if (self) {
        _user_id = @"";
        _username = @"";
        _type = @"";
        _pwd = @"";
        _email = @"";
        _avatarLink = @"";
        
    }
    return self;
}

+ (instancetype)userWithDictionary:(NSDictionary *)dictionary {
    GUser *obj = [[GUser alloc] init];
    
    obj.username = [dictionary objectForKey:@"username"];
    obj.pwd = [dictionary objectForKey:@"pwd"];
    obj.type = [dictionary objectForKey:@"type"];
    obj.user_id = [dictionary objectForKey:@"user_id"];
    obj.email = [dictionary objectForKey:@"email"];
    obj.avatarLink = [dictionary objectForKey:@"avatarLink"];
    
    return obj;
}

- (void)loadUser {
    _username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    _pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"pwd"];
    _type = [[NSUserDefaults standardUserDefaults] objectForKey:@"type"];
    _user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    _email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    _avatarLink = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarLink"];
}

- (void)saveUser {
    
    [[NSUserDefaults standardUserDefaults] setValue:self.username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setValue:self.pwd forKey:@"pwd"];
    [[NSUserDefaults standardUserDefaults] setValue:self.type forKey:@"type"];
    [[NSUserDefaults standardUserDefaults] setValue:self.user_id forKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] setValue:self.email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setValue:self.avatarLink forKey:@"avatarLink"];
    
}

@end
