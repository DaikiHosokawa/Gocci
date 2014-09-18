//
//  LoginViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>


@interface LoginViewController : UIViewController<FBLoginViewDelegate>

@property (nonatomic) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;

@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@end
