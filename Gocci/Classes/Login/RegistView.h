//
//  RegistView.h
//  Gocci
//
//  Created by ArzenalZkull on 3/13/15.
//  Copyright (c) 2015 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import "APIClient.h"
#import "GUser.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSession.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <Social/SLRequest.h>
#import <QuartzCore/QuartzCore.h>
#import "STTwitter.h"



typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that

@interface RegistView : UIView <UITextFieldDelegate,UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UITextField *tfUsername;
@property (nonatomic, retain) IBOutlet UIButton *btnRegist;
;

- (IBAction)tap_link:(id)sender;
@property (nonatomic, retain) NSString *consumerKeyTextField;
@property (nonatomic, retain) NSString *consumerSecretTextField;

@property (weak, nonatomic) IBOutlet UIView *ruleView;
@property (weak, nonatomic) IBOutlet UIButton *ruleCancel;
@property (weak, nonatomic) IBOutlet UIWebView *ruleWebView;

-(IBAction)btnClose_clicked:(id)sender;
-(IBAction)btnRegistLocal_clicked:(id)sender;
-(void) initComponent;

@end
