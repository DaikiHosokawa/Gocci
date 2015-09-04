//
//  SplashViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/25.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "const.h"
#import "SplashViewController.h"
#import "APIClient.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "SVProgressHUD.h"
#import "TutorialPageViewController.h"

@implementation SplashViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SPLASH_TIME * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        
    //identity_id is exist
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"]){
        
        //execute Login API
        [APIClient Login:[[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"] handler:^(id result, NSUInteger code, NSError *error)
        {
            NSLog(@"Login result:%@ error:%@",result,error);
            
            //Login API success
            if([result[@"code"] integerValue] == 200){
                
                [SVProgressHUD show];
                
                //save user data
                NSString* username = [result objectForKey:@"username"];
                NSString* picture = [result objectForKey:@"profile_img"];
                NSString* user_id = [result objectForKey:@"user_id"];
                NSString* token = [result objectForKey:@"token"];
                [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] setValue:picture forKey:@"avatarLink"];
                [[NSUserDefaults standardUserDefaults] setValue:user_id forKey:@"user_id"];
                [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"token"];
                
                //save badge num
                int numberOfNewMessages = [[result objectForKey:@"badge_num"] intValue];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
                [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
                UIApplication *application = [UIApplication sharedApplication];
                application.applicationIconBadgeNumber = numberOfNewMessages;
                [ud synchronize];
                
                //create credentialProvider
                AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION
                                                                                                                identityPoolId:COGNITO_POOL_ID];
                
                AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
                
                [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                
                //unique provider insert
                credentialsProvider.logins = @{ @"test.login.gocci": [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
                
                //refresh Cognito
                [[credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
                    // Your handler code heredentialsProvider.identityId;
                    NSLog(@"logins: %@", credentialsProvider.logins);
                    NSLog(@"task:%@",task);
                    // return [self refresh];
                    return nil;
                }];

                
                [self performSegueWithIdentifier:@"goTimeline" sender:self];
            }
        }];
        
    }else{
        
        //identity_id is empty case
        
        //prepare os string
        NSString *os = [@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion];
        
        //exist username & pic
        if (([[NSUserDefaults standardUserDefaults] valueForKey:@"avatarLink"]) && ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"])){
            
            //execute Conversion API
            [APIClient Conversion:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] profile_img:[[NSUserDefaults standardUserDefaults] valueForKey:@"avatarLink"] os:os model:[UIDevice currentDevice].model register_id:[[NSUserDefaults standardUserDefaults] valueForKey:@"STRING"] handler:^(id result, NSUInteger code, NSError *error) {
                
                NSLog(@"Conversion result:%@ error:%@",result,error);
                
                //Success
                if([result[@"code"] integerValue] == 200){
                    [SVProgressHUD show];
                    
                    //save user data
                    NSString* username = [result objectForKey:@"username"];
                    NSString* picture = [result objectForKey:@"profile_img"];
                    NSString* user_id = [result objectForKey:@"user_id"];
                    NSString* identity_id = [result objectForKey:@"identity_id"];
                    NSString* token = [result objectForKey:@"token"];
                    [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
                    [[NSUserDefaults standardUserDefaults] setValue:picture forKey:@"avatarLink"];
                    [[NSUserDefaults standardUserDefaults] setValue:user_id forKey:@"user_id"];
                    [[NSUserDefaults standardUserDefaults] setValue:identity_id forKey:@"identity_id"];
                    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"token"];

                    //save badge num
                    int numberOfNewMessages = [[result objectForKey:@"badge_num"] intValue];
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
                    [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
                    UIApplication *application = [UIApplication sharedApplication];
                    application.applicationIconBadgeNumber = numberOfNewMessages;
                    [ud synchronize];
                    
                    
                    //create credentialProvider
                    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:COGNITO_POOL_REGION
                                                                                                                    identityPoolId:COGNITO_POOL_ID];
                    
                    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
                    
                    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                    
                    credentialsProvider.logins = @{ @"test.login.gocci": [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
                    
                    //refresh and syncronize console
                    [[credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
                        // Your handler code heredentialsProvider.identityId;
                        NSLog(@"logins: %@", credentialsProvider.logins);
                        NSLog(@"task:%@",task);
                        // return [self refresh];
                        return nil;
                    }];
                    
                    [self performSegueWithIdentifier:@"goTimeline" sender:self];
                    
                }
                
            }];
        }else{
            
            //Login & conversion is Failed
            NSLog(@"tutorialへ");
            // FirstScene と SecondScene が同じ Storyboard にある場合
            TutorialPageViewController *tutorialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
            [self presentViewController:tutorialViewController animated:YES completion:nil];
        }
    }
    
        });
    
}

-(void)viewDidAppear{
    
    [super viewDidAppear:YES];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}


@end
