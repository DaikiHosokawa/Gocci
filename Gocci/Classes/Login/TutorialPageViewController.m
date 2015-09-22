//
//  TutorialPageViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/28.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "const.h"
#import "util.h"

#import "NetOp.h"

#import "TutorialPageViewController.h"
#import "APIClient.h"
#import "AppDelegate.h"


#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "APIClientLimits.h"



@interface TutorialPageViewController (){
    //NSArray *pages;
}



@property (retain, nonatomic) NSMutableArray *pages;
@property (strong, nonatomic) UIPageViewController *pageController;

@property (strong, nonatomic) FBSDKLoginManager *facebookLogin;



@end

@implementation TutorialPageViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:TWITTER_CONSUMER_KEY andSecret:TWITTER_CONSUMER_SECRET];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    
    UIViewController *page1 = [self.storyboard instantiateViewControllerWithIdentifier:@"page1"];
    UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"page2"];
    UIViewController *page3 = [self.storyboard instantiateViewControllerWithIdentifier:@"page3"];
    UIViewController *page4 = [self.storyboard instantiateViewControllerWithIdentifier:@"page4"];

    
    UIButton *ruleButton = (UIButton *)[page3.view viewWithTag:2];
    if(ruleButton) {
        [ruleButton addTarget:self action:@selector(ruleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.username = (UITextField *)[page3.view viewWithTag:3];
    [self.username addTarget:self
                  action:@selector(usernameChanged:)
        forControlEvents:UIControlEventEditingChanged];

#ifdef INDEVEL
    self.username.text = [[[NSProcessInfo processInfo] globallyUniqueString] substringToIndex:8];
#endif
    
    self.popupView = (UIView *)[page3.view viewWithTag:4];
    self.popupWebView = (UIWebView *)[page3.view viewWithTag:5];
    self.popupCancel = (UIButton *)[page3.view viewWithTag:6];
    self.popuptitle = (UILabel *)[page3.view viewWithTag:7];
    
    self.registerButton = (UIButton *)[page3.view viewWithTag:200];
    [self.registerButton addTarget:self action:@selector(registerUsernameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *privacyButton = (UIButton *)[page3.view viewWithTag:8];
    [privacyButton addTarget:self action:@selector(privacyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *FacebookButton = (UIButton *)[page4.view viewWithTag:1];
    [FacebookButton addTarget:self action:@selector(FacebookTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *TwitterButton = (UIButton *)[page4.view viewWithTag:2];
    [TwitterButton addTarget:self action:@selector(TwitterTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *notAuthButton = (UIButton *)[page4.view viewWithTag:3];
    [notAuthButton addTarget:self action:@selector(unAuthTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    // load the view controllers in our pages array
    self.pages = [[NSMutableArray alloc] initWithObjects:page1, page2, page3, nil];
#ifdef INDEVEL
   // self.pages = [[NSMutableArray alloc] initWithObjects:page3, nil];
#endif

    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [self.pageController setDelegate:self];
    [self.pageController setDataSource:self];
    
    [[self.pageController view] setFrame:[[self view] bounds]];
    NSArray *viewControllers = [NSArray arrayWithObject:[self.pages objectAtIndex:0]];
    [self.pageControl setCurrentPage:0];
    

    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    
    [self.view addSubview:self.pageControl];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    [self.view sendSubviewToBack:[self.pageController view]];
}


- (void)usernameChanged:(id)sender {
    //self.registerButton.enabled = self.username.text.length != 0;
}



#pragma mark - Username register Page


- (void)registerUsernameClicked:(id)sender {
    
    if (self.username.text.length > 0 && self.username.text.length <= MAX_USERNAME_LENGTH) {
        self.registerButton.enabled = false;
        self.username.enabled = false;
        
        [self registerUsername:self.username.text];
    }
}



-(void)registerUsername:(NSString*)username {
    
    NSLog(@"=== Trying to register with username: %@", username);
    
    [NetOp registerUsername:username andThen:^(NetOpResult errorCode, NSString *errorMsg)
    {
        switch (errorCode) {
     
            case NETOP_SUCCESS:
                // transition to SNS page
                [self.pages addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"page4"]];
                [self.pageController setViewControllers:[NSArray arrayWithObject:[self.pages lastObject]]
                                              direction:UIPageViewControllerNavigationDirectionForward
                                               animated:YES
                                             completion:nil];
                [self.pageControl setCurrentPage:3];
                break;
                
            case NETOP_USERNAME_ALREADY_IN_USE:
                NSLog(@"=== Username '%@'already registerd by somebody else :(", username);
                self.registerButton.enabled = true;
                self.username.enabled = true;
                
                [[[UIAlertView alloc] initWithTitle:@"" message:@"このユーザー名はすでに使われております" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                break;
                
            default:
                // TODO no internet?? msg to the user
                NSLog(@"=== Register failed: %@", errorMsg);
                self.registerButton.enabled = true;
                self.username.enabled = true;
                break;
        }
    }];
    
}





#pragma mark - Last SNS Page


- (void)ruleButtonTapped:(id)sender{
    NSLog(@"rule");
    
    self.popuptitle.text = @"利用規約";
    
    self.popupView.hidden = NO;
    self.popupWebView.delegate = self;
    self.popupWebView.scalesPageToFit = YES;
    [self.popupView addSubview:self.popupWebView];
    
    NSURL *url = [NSURL URLWithString:@"http://inase-inc.jp/rules/"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.popupWebView loadRequest:req];
    
    // 画像を指定したボタン例文
    UIImage *img = [UIImage imageNamed:@"btn_delete_white.png"];  // ボタンにする画像を生成する
    [self.popupCancel setBackgroundImage:img forState:UIControlStateNormal];  // 画像をセットする
    // ボタンが押された時にhogeメソッドを呼び出す
    [self.popupCancel addTarget:self
                         action:@selector(closePopupView) forControlEvents:UIControlEventTouchUpInside];
}



- (void)privacyButtonTapped:(id)sender{
    NSLog(@"privacy");
    
    self.popuptitle.text = @"プライバシーポリシー";
    
    self.popupView.hidden = NO;
    self.popupWebView.delegate = self;
    self.popupWebView.scalesPageToFit = YES;
    [self.popupView addSubview:self.popupWebView];
    
    NSURL *url = [NSURL URLWithString:@"http://inase-inc.jp/rules/privacy/"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.popupWebView loadRequest:req];
    
    // 画像を指定したボタン例文
    UIImage *img = [UIImage imageNamed:@"btn_delete_white.png"];  // ボタンにする画像を生成する
    [self.popupCancel setBackgroundImage:img forState:UIControlStateNormal];  // 画像をセットする
    // ボタンが押された時にhogeメソッドを呼び出す
    [self.popupCancel addTarget:self
                         action:@selector(closePopupView) forControlEvents:UIControlEventTouchUpInside];
}



#pragma mark - Facefuck

- (void)FacebookTapped:(id)sender{

    NSLog(@"Facebook clicked");


    if (!self.facebookLogin){
        [FBSDKSettings setAppID:FACEBOOK_APP_ID];
        self.facebookLogin = [FBSDKLoginManager new];
    }
    

    [self.facebookLogin logInWithReadPermissions:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"Error logging in with FB: %@", error.localizedDescription]);
        }
        else if (result.isCancelled) {
            // Login canceled
            NSLog(@"User dont want to login with facefuck");
        }
        else {
            // Login Success
            NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
            NSLog(@"###### Facefuck Login Success!  Token: %@", token);
            
            [APIClient connectWithSNS:FACEBOOK_PROVIDER_STRING
                                token:token
                    profilePictureURL:@"none"
                              handler:^(id result, NSUInteger code, NSError *error)
             {
                 
                 NSLog(@"=== Facefuck connection result: %@ error :%@", result, error);
                 
                 // TODO more error handling
                 if (!error && [result[@"code"] integerValue] == 200){
                     NSLog(@"##### HOLY JESUS, we have facefuck connection! Profile pic: %@", result[@"profile_img"]);
                 }
             }];
        }
         // TODO ugly as hell
    }];
    
}

#pragma mark - Twitter

- (void)TwitterTapped:(id)sender{
    
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Login fail!!!");
        
        NSLog(@"FHSTwitterEngine.sharedEngine.authenticatedUsername %@", FHSTwitterEngine.sharedEngine.authenticatedUsername);
        NSLog(@"FHSTwitterEngine.sharedEngine.authenticatedID %@", FHSTwitterEngine.sharedEngine.authenticatedID);
   
        NSLog(@"COGNITO FORMAT 2: %@", [[FHSTwitterEngine sharedEngine] cognitoFormat]);
        
        
        
        [APIClient connectWithSNS:TWITTER_PROVIDER_STRING
                            token:[[FHSTwitterEngine sharedEngine] cognitoFormat]
                profilePictureURL:@"none"
                          handler:^(id result, NSUInteger code, NSError *error)
         {
             
             NSLog(@"=== TWITTER connection result: %@ error :%@", result, error);
             
             // TODO more error handling
             if (!error && [result[@"code"] integerValue] == 200){
                 NSLog(@"##### HOLY JESUS, we have TWITTER connection! Profile pic: %@", result[@"profile_img"]);
             }
         }];
    }];
    [self presentViewController:loginController animated:YES completion:nil];
    
}



- (void)unAuthTapped:(id)sender{
    
    if  ([self.username.text length] != 0)
    {
        NSLog(@"unAuth");
        
        //unAuth and go Timeline processing
        
        
    }else{
        NSString *alertMessage = @"ユーザー名を入力してください";
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show];
    }
}



-(void)closePopupView{
    self.popupView.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    [self resignFirstResponder];
    
    NSLog(@"text:%@",textField.text);
    
    return YES;
}







#pragma mark - PageViewController Stuff

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    //TODO ugly code copied from tutorial
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];    // get the index of the current view controller on display
    [self.pageControl setCurrentPage:self.pageControl.currentPage+1];   // move the pageControl indicator to the next page
    
    // check if we are at the end and decide if we need to present the next viewcontroller
    if ( currentIndex < [self.pages count]-1) {
        return [self.pages objectAtIndex:currentIndex+1];
    }
    return nil;
}


- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    //TODO ugly code copied from tutorial
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];    // get the index of the current view controller on display
    [self.pageControl setCurrentPage:self.pageControl.currentPage-1];                   // move the pageControl indicator to the next page
    
    // check if we are at the beginning and decide if we need to present the previous viewcontroller
    if ( currentIndex > 0) {
        return [self.pages objectAtIndex:currentIndex-1];                   // return the previous viewcontroller
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
