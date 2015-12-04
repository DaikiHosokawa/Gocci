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

#import "APIClientLimits.h"

#import "Swift.h"

#import <CoreLocation/CoreLocation.h>


@interface TutorialPageViewController ()<CLLocationManagerDelegate,UIAlertViewDelegate>{
    //NSArray *pages;
    CGPoint originalCenter;
}



@property (retain, nonatomic) NSMutableArray *pages;
@property (strong, nonatomic) UIPageViewController *pageController;


@end

@implementation TutorialPageViewController



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIViewController *page1 = [self.storyboard instantiateViewControllerWithIdentifier:@"page1"];
    UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"page2"];
    UIViewController *page3 = [self.storyboard instantiateViewControllerWithIdentifier:@"page3"];
    
    
    UIButton *ruleButton = (UIButton *)[page3.view viewWithTag:2];
    if(ruleButton) {
        [ruleButton addTarget:self action:@selector(ruleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.username = (UITextField *)[page3.view viewWithTag:3];
    
    
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
    
    // Keyboard event appear and hide
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardAppear:) name:UIKeyboardWillShowNotification object:nil];
    
    // safe center to return here after the keyboard has appeard
    self->originalCenter = self.view.center;
   
    
}

-(void)onKeyboardHide:(NSNotification *)notification
{
    self.view.center = self->originalCenter;
}

-(void)onKeyboardAppear:(NSNotification *)notification
{
    self.view.center = CGPointMake(self->originalCenter.x, self->originalCenter.y - 200);
}




#pragma mark - Username register Page


- (void)registerUsernameClicked:(id)sender {
  
    
        if (self.username.text.length > 0 && self.username.text.length <= MAX_USERNAME_LENGTH) {
            self.registerButton.enabled = false;
            self.username.enabled = false;
            
            [self registerUsername:self.username.text];
        }
        else {
        UIAlertView *requestAgain  =[[UIAlertView alloc] initWithTitle:@"設定画面より位置情報をONにしてください" message:@"Gocci登録には位置情報が必要です" delegate:self cancelButtonTitle:nil otherButtonTitles:@"設定する", nil];
            [requestAgain show];
    }
}


-(void)loginAndTransit {
    [[Util dirtyBackEndLoginWithUserDefData] continueWithBlock:^id(AWSTask *task) {
        // transition to SNS page
        [self.pages addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"page4"]];
        [self.pageController setViewControllers:[NSArray arrayWithObject:[self.pages lastObject]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
        [self.pageControl setCurrentPage:3];
        return nil;
    }];
}



-(void)registerUsername:(NSString*)username {
    
    NSLog(@"=== Trying to register with username: %@", username);
    
    [NetOp registerUsername:username andThen:^(NetOpResult errorCode, NSString *errorMsg)

    {
        if ( errorCode == NETOP_SUCCESS){
            [self.pages addObject:[self.storyboard instantiateViewControllerWithIdentifier:@"page4"]];
            [self.pageController setViewControllers:[NSArray arrayWithObject:[self.pages lastObject]]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
            [self.pageControl setCurrentPage:3];
            [Util dirtyBackEndSignUpWithUserDefData];
            return;
        }
        
        switch (errorCode) {
                
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



-(void)closePopupView {
    self.popupView.hidden = YES;
}



#pragma mark - PageViewController Stuff

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];        [self.pageControl setCurrentPage:self.pageControl.currentPage+1];      if ( currentIndex < [self.pages count]-1) {
        return [self.pages objectAtIndex:currentIndex+1];
    }
    return nil;
}


- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];       [self.pageControl setCurrentPage:self.pageControl.currentPage-1];                      if ( currentIndex > 0) {
        return [self.pages objectAtIndex:currentIndex-1];                }
    return nil;
}




- (IBAction)ReturnTutorial:(UIStoryboardSegue *)segue
{
    NSLog(@"go back to tutorial");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 121 && buttonIndex == 0)
    {
        //code for opening settings app in iOS 8
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


@end
