//
//  TutorialPageViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/28.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "const.h"
#import "util.h"

#import "TutorialPageViewController.h"
#import "APIClient.h"
#import "AppDelegate.h"

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>



@interface TutorialPageViewController (){
    //NSArray *pages;
}



@property (retain, nonatomic) NSMutableArray *pages;
@property (strong, nonatomic) UIPageViewController *pageController;

@property (strong, nonatomic) UIViewController *lastPage;

@property (strong, nonatomic) FBSDKLoginManager *facebookLogin;



@end

@implementation TutorialPageViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIViewController *page1 = nil;
    UIViewController *page2 = nil;
    UIViewController *page3 = nil;
    UIViewController *page4 = nil;
    
    //3.5inchと4inchを読み分けする
    CGRect rect = [UIScreen mainScreen].bounds;
    
    if (rect.size.height == 480) {
        page1 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
        page2 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
        page3 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
        page4 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    }
    
    if (rect.size.height == 568) {
        page1 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
        page2 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
        page3 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
        page4 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    }
    
    //4.7inch対応
    if (rect.size.height == 667) {
         page1 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
         page2 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
         page3 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
         page4 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    }
    
    //5.5inch対応
    if (rect.size.height == 736) {
        page1 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
        page2 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
        page3 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
        page4 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    }
    
    //TODO if page1 is still nil here, the programm will crash. So any new iPhone or iPad or so am BOOM
    
    
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
    
    UIButton *registerButton = (UIButton *)[page3.view viewWithTag:200];
    [registerButton addTarget:self action:@selector(registerUsernameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.lastPage = page4;

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


- (void)myTextFieldDidChange:(id)sender {
    //self.registerButton.enabled = self.username.text.length != 0;
}



#pragma mark - Username register Page


- (void)registerUsernameClicked:(id)sender{


    
    
    if (self.username.text.length > 0) {
        [self registerUsername:self.username.text];
    }
    else {
        // TODO mesg to the user, edit box still empty
        // UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:@"_____ STILL EMPTY _____" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        // [alrt show];
    }
    
   
}



-(void)registerUsername:(NSString*)username {
    
    NSLog(@"=== Trying to register with username: %@", username);
    
    NSString *reg_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"STRING"];
    
#ifdef INDEVEL
    if (!reg_id) {
        reg_id = [util fakeDeviceID];
        NSLog(@"=== WARNING uniq register_id not availible. Use random string for testing purpose:");
        NSLog(@"%@", reg_id);
    }
#endif
    
    assert(reg_id); // looks like a provisioning profile is needed for this...
    
    // execute Signup API
    [APIClient Signup:username
                   os:[@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion]
                model:[UIDevice currentDevice].model
          register_id:reg_id
              handler:^(id result, NSUInteger code, NSError *error)
     {
         
         NSLog(@"=== Register result: %@ error :%@", result, error);
         
         if (!error) { // TODO needs a msg to the user. what does happen when no connected to the internet?
             
             //success
             if ([result[@"code"] integerValue] == 200) {
                 
                 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                 
                 //save user data
                 [ud setValue:[result objectForKey:@"username"] forKey:@"username"];
                 [ud setValue:[result objectForKey:@"profile_img"] forKey:@"avatarLink"];
                 [ud setValue:[result objectForKey:@"user_id"] forKey:@"user_id"];
                 [ud setValue:[result objectForKey:@"identity_id"] forKey:@"identity_id"];
                 [ud setValue:[result objectForKey:@"token"] forKey:@"token"];
                 
                 //save badge num
                 int numberOfNewMessages = [[result objectForKey:@"badge_num"] intValue];
                 NSLog(@"numberOfNewMessages:%d", numberOfNewMessages);
                 [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
                 
                 UIApplication *application = [UIApplication sharedApplication];
                 application.applicationIconBadgeNumber = numberOfNewMessages;
                 [ud synchronize];
                 
                 // some logging
                 NSLog(@"======================================================================");
                 NSLog(@"=================== USER REGISTRATION SUCCESSFUL =====================");
                 NSLog(@"======================================================================");
                 NSLog(@"    username:    %@", [result objectForKey:@"username"]);
                 NSLog(@"    user id:     %@", [result objectForKey:@"user_id"]);
                 NSLog(@"    identity_id: %@", [result objectForKey:@"identity_id"]);
                 NSLog(@"======================================================================");
                 
                 
                 // user is now a developer authenticated user. cognito is handelt on the server side (thanks murata-san^^)
                                
                 // transition to SNS page
                 [self.pages addObject:_lastPage];
                 NSArray *viewControllers = [NSArray arrayWithObject:[self.pages lastObject]];
                 [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                 [self.pageControl setCurrentPage:3];
                 
             }
             else{ // TODO would be nice to handle this not as the default case. Other server side error are possible as well...
                 
                 NSLog(@"===================== USER REGISTRATION FAILED =======================");
                 UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:@"このユーザー名はすでに使われております" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alrt show];
                 NSLog(@"%@", result[@"code"]);
                
             }

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



- (void)TwitterTapped:(id)sender{
    
    if  ([self.username.text length] != 0)
    {
        NSLog(@"Twitter");
        
        //Twitter Link processing
        
        
        
    }else{
        NSString *alertMessage = @"ユーザー名を入力してください";
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show];
    }
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
