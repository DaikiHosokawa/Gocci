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

#import "SVProgressHUD.h"
#import "TutorialPageViewController.h"

#import "NetOp.h"
#import "util.h"



@implementation SplashViewController

-(void)viewDidLoad{
    // uncomment to test the conversion API
//    [util removeAccountSpecificDataFromUserDefaults];
//    [[NSUserDefaults standardUserDefaults] setValue:@"conversr1" forKey:@"username"];
//    [[NSUserDefaults standardUserDefaults] setValue:@"http://dwdwdw.dwdwdw.dww.de/img.jpg" forKey:@"avatarLink"];
    
    [super viewDidLoad];
    
    
    //self.navigationController.
    
    // TODO we can do the network operations while we wait here, I will fix this later
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SPLASH_TIME * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        NSString *iid =      [[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"];
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        NSString *avatar =   [[NSUserDefaults standardUserDefaults] valueForKey:@"avatarLink"];
        
        // registerd user, already using gocci
        if (iid){
            [NetOp loginWithIID:iid andThen:^(NetOpResult ecode, NSString *emsg)
            {
                switch (ecode) {
                    case NETOP_SUCCESS:
                        //[self performSegueWithIdentifier:@"goTimeline" sender:self];
                        [self goToTutorial];

                        break;
                    case NETOP_NETWORK_ERROR:
                        // TODO not network msg to the user?
                        break;
                        
                    default:
                        // TODO What to to if the user can't login with this id??? should never happen, but what if? How about
                        // [util removeAccountSpecificDataFromUserDefaults];
                        // [self goToTutorial];
                        break;
                }
            }];
            
            return;
        }

        // conversion API needed
        if( username && avatar ){

            [NetOp loginWithAPIV2Conversation:username
                                       avatar:avatar
                                      andThen:^(NetOpResult ecode, NSString *emsg)
            {
                switch (ecode) {
                    case NETOP_SUCCESS:
                        [self performSegueWithIdentifier:@"goTimeline" sender:self];
                        break;
                    case NETOP_NETWORK_ERROR:
                        // TODO not network msg to the user?
                        break;
                        
                    default:
                        // TODO What to to if the user can't login with this id??? should never happen, but what if? How about
                        // [util removeAccountSpecificDataFromUserDefaults];
                        // [self goToTutorial];
                        break;
                }
                [self performSegueWithIdentifier:@"goTimeline" sender:self];
            }];
            
            return;
        }
        
        // first startup, show tutorial
        [self goToTutorial];
    });
        

    
}


-(void)goToTutorial{
    
    TutorialPageViewController *tutorialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
    [self presentViewController:tutorialViewController animated:YES completion:nil];
    
}

-(void)viewDidAppear{
    
    [super viewDidAppear:YES];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}


@end
