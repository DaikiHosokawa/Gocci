
//  LoginViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TimelineTableViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "TutorialView.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "SigninView.h"
#import "GUser.h"
#import "RegistView.h"
#import "UIImage+BlurEffect.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "APIClient.h"
#import "AFHTTPRequestOperation.h"



#define kActiveLogin @"ActiveLogin"
#define kActiveCancel @"kActiveCancel"

@import Social;

@interface LoginViewController ()
<TutorialViewDelegate, FBLoginViewDelegate> {
    UIImageView *bgBlur;
}

@property (nonatomic, strong) TutorialView *tutorialView;

@property (nonatomic, retain) IBOutlet UIButton *btnRegist;
@property (nonatomic, retain) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _button.layer.borderColor = [UIColor grayColor].CGColor;
    _button.layer.borderWidth = 0.5f;
    
    
    
    // 初回起動時のみの動作
    AppDelegate *appDelegate = [[AppDelegate alloc]init];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate isFirstRun]) {
        self.tutorialView = [TutorialView showInView:self.view delegate:self];
    }
    
    //テスト
    //テスト
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(autoLogin)
                                                 name:kActiveLogin
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancel)
                                                 name:kActiveCancel
                                               object:nil];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self autoLogin];
}

#pragma mark - Functions
-(void) cancel {
    _btnLogin.enabled = YES;
    _btnRegist.enabled = YES;
    [bgBlur removeFromSuperview];
}

-(void) autoLogin {
    
    
    _btnLogin.enabled = YES;
    _btnRegist.enabled = YES;
    [bgBlur removeFromSuperview];
    
    [SVProgressHUD show];
    
    [APIClient Login:[[NSUserDefaults standardUserDefaults] valueForKey:@"identity_id"] handler:^(id result, NSUInteger code, NSError *error) {
        NSLog(@"Login result:%@ error:%@",result,error);
        if((code = 200)){
            NSString* username = [result objectForKey:@"username"];
            NSString* picture = [result objectForKey:@"profile_img"];
            NSString* user_id = [result objectForKey:@"user_id"];
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
            [[NSUserDefaults standardUserDefaults] setValue:picture forKey:@"picture"];
            [[NSUserDefaults standardUserDefaults] setValue:user_id forKey:@"user_id"];
            
            [self performSegueWithIdentifier:@"ShowTabBarController" sender:self];
        }
    }];
}


-(void) addBackgroundEffect {
    //Get a screen capture from the current view.
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0f);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    backgroundImage = [backgroundImage applyLightEffect];
    
    bgBlur = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [bgBlur addGestureRecognizer:tap];
    bgBlur.image = backgroundImage;
    [self.view addSubview:bgBlur];
    
    _btnLogin.enabled = NO;
    _btnRegist.enabled = NO;
    
}

-(void) dismissKeyboard:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

#pragma mark - Action

//「Gocciを始める」を押す
- (IBAction)facebookButtonTapped:(id)sender {
    
    [self addBackgroundEffect];
    
    NSString *nibName = @"RegistView";
    AppDelegate *dele = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    switch (dele.screenType) {
        case 2:
            nibName = @"RegistView35";
            break;
            
        case 3:
            nibName = @"RegistView47";
            break;
            
        case 4:
            nibName = @"RegistView55";
            break;
            
        default:
            break;
    }
    
    RegistView *registView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil] lastObject];;
    [registView initComponent];
    registView.frame = CGRectMake((self.view.frame.size.width - registView.frame.size.width)/2, 80, registView.frame.size.width, registView.frame.size.height);
    [self.view addSubview:registView];
    
    return;
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

//Twitterログインボタンを押す
- (IBAction)twitterButtonTapped:(id)sender {
    
    [self addBackgroundEffect];
    
    SigninView *registView = [[[NSBundle mainBundle] loadNibNamed:@"SigninView" owner:nil options:nil] lastObject];;
    [registView initComponent];
    registView.frame = CGRectMake((self.view.frame.size.width - registView.frame.size.width)/2, 20, registView.frame.size.width, registView.frame.size.height);
    [self.view addSubview:registView];
    
}



#pragma mark - TutorialView Delegate

- (void)tutorialDidFinish:(TutorialView *)view
{
    // 位置情報サービス利用の利用確認
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate checkGPS];
    
    // チュートリアル終了
    [self.tutorialView dismiss];
}


@end