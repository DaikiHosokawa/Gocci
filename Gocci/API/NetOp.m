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
#import "GocciTest-Swift.h"



#import "APIClient.h"




@implementation NetOp : NSObject






+ (void)loginWithIID:(NSString *)iid andThen:(void (^)(NetOpResult errorCode, NSString *errorMsg))afterBlock
{
    [APIClient Login:iid handler:^(id result, NSUInteger code, NSError *error)
    {
        NSLog(@"??????????????? %@ %lu %@", result, (unsigned long)code, error);
        
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
        
        //save badge num
        [Util setBadgeNumber:[[result objectForKey:@"badge_num"] intValue]];
        
        // some logging
        NSLog(@"======================================================================");
        NSLog(@"====================== USER LOGIN SUCCESSFUL =========================");
        NSLog(@"======================================================================");
        NSLog(@"    username:    %@", [result objectForKey:@"username"]);
        NSLog(@"    user id:     %@", [result objectForKey:@"user_id"]);
        NSLog(@"    identity_id: %@", [result objectForKey:@"identity_id"]);
        NSLog(@"======================================================================");
        
        // Setup AWS credentials
        [AWS prepareWithIdentityID:iid
                            userID:[result objectForKey:@"user_id"]
                          devAuthToken:[result objectForKey:@"token"]];
        
        afterBlock(NETOP_SUCCESS, nil);
        
    }];
}




+ (void)loginWithSNS:(NSString *)provider SNSToken:(NSString*)token andThen:(void (^)(NetOpResult errorCode, NSString *errorMsg))afterBlock
{
    
    // AWS get iid
    
    [AWS prepareWithSNSProvider:provider SNStoken:token];
    //[AWS prepare];
    //[[AWS sharedInstance] addLoginAuthenticationProvider:provider authToken:token];
    
    NSString *iid = [[AWS sharedInstance] iid];
    
    if (iid == nil) {
        NSLog(@"iid nil:(");
        return;
    }
    
    
    [APIClient loginWithSNS:iid
                         os:[@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion]
                      model:[UIDevice currentDevice].model
                register_id:[Util getRegisterID]
                    handler:^(id result, NSUInteger code, NSError *error)
     {
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
         
         //save badge num
         [Util setBadgeNumber:[[result objectForKey:@"badge_num"] intValue]];
         
         // some logging
         NSLog(@"======================================================================");
         NSLog(@"====================== USER LOGIN SUCCESSFUL =========================");
         NSLog(@"======================================================================");
         NSLog(@"    username:    %@", [result objectForKey:@"username"]);
         NSLog(@"    user id:     %@", [result objectForKey:@"user_id"]);
         NSLog(@"    identity_id: %@", [result objectForKey:@"identity_id"]);
         NSLog(@"======================================================================");
         
         // AWS setup not nessery because it was already setup earlier to retrieve the iid
         NSLog(@"XXXXXXXXXXXXXXXXXX %@", result);

         
         afterBlock(NETOP_SUCCESS, nil);
         
     }];
}



+ (void)registerUsername:(NSString *)username andThen:(void (^)(NetOpResult errorCode, NSString *errorMsg))afterBlock
{

    [APIClient Signup:username
                   os:[@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion]
                model:[UIDevice currentDevice].model
          register_id:[Util getRegisterID]
              handler:^(id result, NSUInteger code, NSError *error)
     {

         // TODO network errors should maybe be handelt in APIClient
         if (!result) {
             NSLog(@"Login result:%@ error:%@",result,error);
             afterBlock(NETOP_NETWORK_ERROR, [error localizedDescription]);
             return;
         }
         
         if([result[@"code"] integerValue] != 200){
             NSLog(@"Login result:%@ error:%@", result, @"username in use");
             afterBlock(NETOP_USERNAME_ALREADY_IN_USE, @"username in use");
             return;
         }
         
         
         //success, user is now a developer authenticated user. cognito is handeld on the server side (thanks murata-san^^)
         NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
         
         //save user data
         [ud setValue:[result objectForKey:@"username"] forKey:@"username"];
         [ud setValue:[result objectForKey:@"profile_img"] forKey:@"avatarLink"];
         [ud setValue:[result objectForKey:@"user_id"] forKey:@"user_id"];
         [ud setValue:[result objectForKey:@"identity_id"] forKey:@"identity_id"];
         
         //save badge num
         [Util setBadgeNumber:[[result objectForKey:@"badge_num"] intValue]];
         
         // some logging
         NSLog(@"======================================================================");
         NSLog(@"=================== USER REGISTRATION SUCCESSFUL =====================");
         NSLog(@"======================================================================");
         NSLog(@"    username:    %@", [result objectForKey:@"username"]);
         NSLog(@"    user id:     %@", [result objectForKey:@"user_id"]);
         NSLog(@"    identity_id: %@", [result objectForKey:@"identity_id"]);
         NSLog(@"======================================================================");
         
         // Setup AWS credentials
//         [AWS prepareWithIdentityID:[result objectForKey:@"identity_id"]
//                    andDevAuthToken:[result objectForKey:@"token"]];
         
         afterBlock(NETOP_SUCCESS, nil);

     }];
}




+ (void)loginWithAPIV2Conversation:(NSString*)username avatar:(NSString*)avatar andThen:(void (^)(NetOpResult errorCode, NSString *errorMsg))afterBlock
{
    [APIClient Conversion:username
              profile_img:avatar
                       os:[@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion]
                    model:[UIDevice currentDevice].model
              register_id:[Util getRegisterID]
                  handler:^(id result, NSUInteger code, NSError *error)
    {
            
        NSLog(@"Conversion result:%@ error:%@",result,error);
        
        //TODO network errors should maybe be handelt in APIClient
        //FIXME
        if (!result) {
            NSLog(@"Login result:%@ error:%@",result,error);
            afterBlock(NETOP_NETWORK_ERROR, [error localizedDescription]);
            return;
        }
        
        if([result[@"code"] integerValue] != 200){
            NSLog(@"Login result:%@ error:%@", result, @"username in use");
            afterBlock(NETOP_USERNAME_ALREADY_IN_USE, @"username in use");
            return;
        }
        
        //success, user is now a developer authenticated user. cognito is handeld on the server side (thanks murata-san^^)
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        //save user data
        [ud setValue:[result objectForKey:@"username"] forKey:@"username"];
        [ud setValue:[result objectForKey:@"profile_img"] forKey:@"avatarLink"];
        [ud setValue:[result objectForKey:@"user_id"] forKey:@"user_id"];
        [ud setValue:[result objectForKey:@"identity_id"] forKey:@"identity_id"];
        
        //save badge num
        [Util setBadgeNumber:[[result objectForKey:@"badge_num"] intValue]];
        
        // some logging
        NSLog(@"======================================================================");
        NSLog(@"=================== USER CONVERSATION SUCCESSFUL =====================");
        NSLog(@"======================================================================");
        NSLog(@"    username:    %@", [result objectForKey:@"username"]);
        NSLog(@"    user id:     %@", [result objectForKey:@"user_id"]);
        NSLog(@"    identity_id: %@", [result objectForKey:@"identity_id"]);
        NSLog(@"======================================================================");
        
        
        // Setup AWS credentials
//        [AWS prepareWithIdentityID:[result objectForKey:@"identity_id"]
//                   andDevAuthToken:[result objectForKey:@"token"]];
        
        
        afterBlock(NETOP_SUCCESS, nil);

            
    }];
}

@end


