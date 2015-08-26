//
//  SplashViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/25.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "SplashViewController.h"
#import "APIClient.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "SVProgressHUD.h"
#import "TutorialViewController.h"

@implementation SplashViewController

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"]){
        
        [APIClient Login:[[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"] handler:^(id result, NSUInteger code, NSError *error) {
            NSLog(@"Login result:%@ error:%@",result,error);
            
            if([result[@"code"] integerValue] == 200){
                
                [SVProgressHUD show];
                
                //NSString* username = [result objectForKey:@"username"];
                
                NSString* username = [result objectForKey:@"username"];
                NSString* picture = [result objectForKey:@"profile_img"];
                NSString* user_id = [result objectForKey:@"user_id"];
                [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] setValue:picture forKey:@"avatarLink"];
                [[NSUserDefaults standardUserDefaults] setValue:user_id forKey:@"user_id"];
                
                //ここをログインのところに追加
                // 新着メッセージ数をuserdefaultに格納(アプリを落としても格納されつづける)
                int numberOfNewMessages = [[result objectForKey:@"badge_num"] intValue];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
                [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
                UIApplication *application = [UIApplication sharedApplication];
                application.applicationIconBadgeNumber = numberOfNewMessages;
                [ud synchronize];
                
                [self performSegueWithIdentifier:@"goTimeline" sender:self];
            }
        }];
        
    }else{
        
        NSString *os = [@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion];
        
        NSLog(@"picture:%@,username:%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"avatarLink"],[[NSUserDefaults standardUserDefaults] valueForKey:@"username"]);
        
        NSDictionary * dic = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
        NSLog(@"defualts:%@", dic);
        
        if (([[NSUserDefaults standardUserDefaults] valueForKey:@"avatarLink"]) && ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"])){
            
            [APIClient Conversion:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] profile_img:[[NSUserDefaults standardUserDefaults] valueForKey:@"avatarLink"] os:os model:[UIDevice currentDevice].model register_id:[[NSUserDefaults standardUserDefaults] valueForKey:@"STRING"] handler:^(id result, NSUInteger code, NSError *error) {
                
                NSLog(@"Conversion result:%@ error:%@",result,error);
                
                if([result[@"code"] integerValue] == 200){
                    [SVProgressHUD show];
                    
                    NSString* username = [result objectForKey:@"username"];
                    NSString* picture = [result objectForKey:@"profile_img"];
                    NSString* user_id = [result objectForKey:@"user_id"];
                    NSString* identityID = [result objectForKey:@"identity_id"];
                    [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
                    [[NSUserDefaults standardUserDefaults] setValue:picture forKey:@"avatarLink"];
                    [[NSUserDefaults standardUserDefaults] setValue:user_id forKey:@"user_id"];
                    [[NSUserDefaults standardUserDefaults] setValue:identityID forKey:@"identity_id"];
                    
                    NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
                    [def setObject:result[@"username"] forKey:@"username"];
                    [def setObject:result[@"identity_id"] forKey:@"identity_id"];
                    [def setObject:result[@"token"] forKey:@"token"];
                    
                    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                                    identityPoolId:@"us-east-1:b563cebf-1de2-4931-9f08-da7b4725ae35"];
                    
                    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
                    
                    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                    
                    credentialsProvider.logins = @{ @"test.login.gocci": [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
                    //master
                    //credentialsProvider.logins = @{ @"login.gocci": [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
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
            NSLog(@"tutorialへ");
            // FirstScene と SecondScene が同じ Storyboard にある場合
            TutorialViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
            [self presentViewController:secondViewController animated:YES completion:nil];
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
