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

@interface LoginViewController : UIViewController

@property (nonatomic) ACAccountStore *accountStore;

@end
