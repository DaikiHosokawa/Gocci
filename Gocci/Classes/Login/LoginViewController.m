
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
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *avatarLink = [[NSUserDefaults standardUserDefaults] valueForKey:@"avatarLink"];
    
    if (username) {
        
        AppDelegate* logindelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        logindelegate.username = username;
        NSString *pictureURL = avatarLink;
        AppDelegate* picturedelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        picturedelegate.userpicture = pictureURL;
        
        NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",username,pictureURL];
        NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/login/"];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse* response;
        NSError* error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                               returningResponse:&response
                                                           error:&error];
        NSLog(@"result:%@",result);
        [self performSegueWithIdentifier:@"ShowTabBarController" sender:self];
    }
    
    
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

//Facebookログインを押す
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
    registView.frame = CGRectMake((self.view.frame.size.width - registView.frame.size.width)/2, 20, registView.frame.size.width, registView.frame.size.height);
    [self.view addSubview:registView];
    
    return;
    
   }

//facebookの各種データ取得
-(void)info{
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            AppDelegate* logindelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            logindelegate.username = name;
            NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID ];
            AppDelegate* picturedelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            picturedelegate.userpicture = pictureURL;
            
            NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",name,pictureURL];
            NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/login/"];
            NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLResponse* response;
            NSError* error = nil;
            NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                   returningResponse:&response
                                                               error:&error];
            NSLog(@"result:%@",result);
			
			[self performSegueWithIdentifier:@"ShowTabBarController" sender:self];	// !!!:dezamisystem・Segue変更

            NSLog(@"FacebookLogin is completed");

            
            NSLog(@"name=%@",name);
            NSLog(@"pict=%@",pictureURL);
            [SVProgressHUD dismiss];
        }
    }];
}

//Twitterログインボタンを押す
- (IBAction)twitterButtonTapped:(id)sender {
    
    [self addBackgroundEffect];
    
    SigninView *registView = [[[NSBundle mainBundle] loadNibNamed:@"SigninView" owner:nil options:nil] lastObject];;
    [registView initComponent];
    registView.frame = CGRectMake((self.view.frame.size.width - registView.frame.size.width)/2, 20, registView.frame.size.width, registView.frame.size.height);
    [self.view addSubview:registView];
    
}


//Twitterの各種データ取得
-(void)info2
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!error) {
			if (user) {
				NSString *userId = [PFTwitterUtils twitter].userId;
				NSLog(@"userId:%@",userId);
				NSString *authToken = [PFTwitterUtils twitter].authToken;
				NSLog(@"authToken:%@",authToken);
				NSString *screenName = [PFTwitterUtils twitter].screenName;
				NSLog(@"screenName:%@",screenName);
				AppDelegate* logindelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
				logindelegate.username = screenName;
				NSString *pictureURL = [[NSString alloc] initWithFormat:@"http://www.paper-glasses.com/api/twipi/%@", screenName];
				AppDelegate* picturedelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
				picturedelegate.userpicture = pictureURL;
				NSLog(@"%@",pictureURL);
            
				NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",screenName,pictureURL];
				NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/login/"];
				NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
				[urlRequest setHTTPMethod:@"POST"];
				[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
				NSURLResponse* response;
				NSError* error = nil;
				NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
													returningResponse:&response
																error:&error];
				NSLog(@"result:%@",result);
//				[self performSegueWithIdentifier:@"goTimeline2" sender:self];
				[self performSegueWithIdentifier:@"ShowTabBarController" sender:self];	// !!!:dezamisystem・Segue変更
			
				NSLog(@"TwitterLogin is completed");
				[SVProgressHUD dismiss];
			}
			else {
				NSLog(@"%s USER IS NULL",__func__);
			}
        }
		else {
			NSLog(@"%s ERROR:%@",__func__, error);
		}
    }];
}


#pragma mark - TutorialView Delegate

- (void)tutorialDidFinish:(TutorialView *)view
{
    // 位置情報サービス利用の確認
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate checkGPS];
    
    // チュートリアル終了
    [self.tutorialView dismiss];
}


@end