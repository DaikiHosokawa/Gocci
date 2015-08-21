
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
#import "APIClient.h"
#import "AFHTTPRequestOperation.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>


#define kActiveLogin @"kActiveLogin"
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
    
    NSLog(@"autoLogin");
    
    _btnLogin.enabled = YES;
    _btnRegist.enabled = YES;
    [bgBlur removeFromSuperview];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud removeObjectForKey:@"identity_id"];  // KEY_Iを削除する
    
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
                
                [self performSegueWithIdentifier:@"ShowTabBarController" sender:self];
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
                    
                    /*
                     AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                     identityPoolId:@"us-east-1:b0252276-27e1-4069-be84-3383d4b3f897"];
                     */
                    
                    
                    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
                    
                    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
                    
                    credentialsProvider.logins = @{ @"login.gocci": [[NSUserDefaults standardUserDefaults] valueForKey:@"token"] };
                    
                    [[credentialsProvider refresh] continueWithBlock:^id(AWSTask *task) {
                        // Your handler code heredentialsProvider.identityId;
                        NSLog(@"logins: %@", credentialsProvider.logins);
                        NSLog(@"task:%@",task);
                        // return [self refresh];
                        return nil;
                    }];
                    
                   
                    [self performSegueWithIdentifier:@"ShowTabBarController" sender:self];
                }
                
            }];
            
        }
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