//
//  util.m
//  Gocci
//
//  Created by Sem on 9/7/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation util : NSObject


+ (NSString*)fakeDeviceID
{
    // worst language ever...
    NSString *r1 = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *r2 = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *str = [NSString stringWithFormat: @"%@%@", r1, r2];
    return [[str stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:64];
}

+ (void)saveDictToUserDefaults:(NSDictionary*)dict
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [dict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        [ud setValue:obj forKey:key];
    }];
    
    [ud synchronize];
}

@end
