//
//  util.m
//  Gocci
//
//  Created by Sem on 9/7/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "util.h"
#import "const.h"

@implementation util : NSObject


+ (void)removeAccountSpecificDataFromUserDefaults
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profile_img"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"identity_id"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"badge_num"];
}


+ (NSString*)fakeDeviceID
{
    // worst language ever...
    NSString *r1 = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *r2 = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *str = [NSString stringWithFormat: @"%@%@", r1, r2];
    return [[str stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:64];
}

+ (NSString*)getRegisterID
{
    NSString *reg_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"register_id"];
    
#ifdef INDEVEL
    if (!reg_id) {
        reg_id = [util fakeDeviceID];
        NSLog(@"=== WARNING uniq register_id not availible. Use random string for testing purpose:");
        NSLog(@"%@", reg_id);
    }
#else
    if (!reg_id) {
        reg_id = @"UNDEFINEDID";
        NSLog(@"=== WARNING uniq register_id not availible. Login API will fail with this register_id: %@", reg_id);
    }
#endif
    
    return reg_id;
}

+ (void)setBadgeNumber:(NSInteger)numberOfNewMessages
{
    // TODO I don't see a reason this has to got to user defaults, however it is read in over 20 places from ud,
    // so this will be fixed in the next version of gocci
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    //save badge num
    NSLog(@"numberOfNewMessages:%ld", (long)numberOfNewMessages);
    [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = numberOfNewMessages;
    [ud synchronize];
}

@end
