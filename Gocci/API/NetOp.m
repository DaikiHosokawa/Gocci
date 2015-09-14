//
//  NetOp.m
//  Gocci
//
//  Created by Markus Wanke on 11.09.15.
//  Copyright © 2015 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NetOp.h"
#import "AWS.h"


#import "APIClient.h"




@implementation NetOp : NSObject

+ (void)loginWithIID:(NSString *)iid andThen:(void (^)(int errorCode, NSString *errorMsg))afterBlock
{
    [APIClient Login:iid handler:^(id result, NSUInteger code, NSError *error){
        
        // TODO network errors should maybe be handelt in APIClient
        if (!result) {
            NSLog(@"Login result:%@ error:%@",result,error);
            afterBlock(NETOP_NETWORK_ERROR, [error localizedDescription]);
            return;
        }
        
        if([result[@"code"] integerValue] != 200){
            NSLog(@"Login result:%@ error:%@",result,@"unregisterd identity_id");
            afterBlock(NETOP_IDENTIFY_ID_NOT_REGISTERD, @"unregisterd identity_id");
            return;
        }
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        //save user data
        [ud setValue:[result objectForKey:@"username"] forKey:@"username"];
        [ud setValue:[result objectForKey:@"profile_img"] forKey:@"avatarLink"];
        [ud setValue:[result objectForKey:@"user_id"] forKey:@"user_id"];
        [ud setValue:[result objectForKey:@"token"] forKey:@"token"];
        
        //save badge num
        int numberOfNewMessages = [[result objectForKey:@"badge_num"] intValue];
        NSLog(@"numberOfNewMessages:%d", numberOfNewMessages);
        [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
        
        UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber = numberOfNewMessages;
        [ud synchronize];
        
        // some logging
        NSLog(@"======================================================================");
        NSLog(@"====================== USER LOGIN SUCCESSFUL =========================");
        NSLog(@"======================================================================");
        NSLog(@"    username:    %@", [result objectForKey:@"username"]);
        NSLog(@"    user id:     %@", [result objectForKey:@"user_id"]);
        NSLog(@"    identity_id: %@", [result objectForKey:@"identity_id"]);
        NSLog(@"======================================================================");
        
        
        [AWS sharedInstance].token = [result objectForKey:@"token"];
        [[AWS sharedInstance] refresh];
        
        afterBlock(NETOP_SUCCESS, nil);
        
    }];
}


@end
  



//GetCredentialsForIdentity




   //      [SVProgressHUD show];

