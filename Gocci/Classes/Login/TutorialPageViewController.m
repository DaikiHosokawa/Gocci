//
//  TutorialPageViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/28.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "TutorialPageViewController.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

@interface TutorialPageViewController (){
    NSArray *pages;
}



@property (retain, nonatomic) NSArray *pages;
@property (strong, nonatomic) UIPageViewController *pageController;

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
        // Do any additional setup after loading the view.
        // instantiate the view controlles from the storyboard
        page1 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
        
        page2 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
        
        page3 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
        
        page4 = [[UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    }
    
    if (rect.size.height == 568) {
        // Do any additional setup after loading the view.
        // instantiate the view controlles from the storyboard
        page1 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
        
        page2 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
        
        page3 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
        
        page4 = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    }
    
    //4.7inch対応
    CGRect rect2 = [UIScreen mainScreen].bounds;
    if (rect2.size.height == 667) {
        // Do any additional setup after loading the view.
        // instantiate the view controlles from the storyboard
         page1 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
        
         page2 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
        
         page3 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
        
         page4 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    
    }
    
    //5.5inch対応
    CGRect rect3 = [UIScreen mainScreen].bounds;
    if (rect3.size.height == 736) {
        // Do any additional setup after loading the view.
        // instantiate the view controlles from the storyboard
        page1 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
        
        page2 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
        
        page3 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
        
        page4 = [[UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    
    }
    
    
    UIButton *ruleButton = (UIButton *)[page3.view viewWithTag:2];
    if(ruleButton) {
        [ruleButton addTarget:self action:@selector(ruleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.username = (UITextField *)[page3.view viewWithTag:3];
    if(self.username) {
        [self.username addTarget:self action:@selector(insertUsername:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }

    
    self.popupView = (UIView *)[page3.view viewWithTag:4];
    self.popupWebView = (UIWebView *)[page3.view viewWithTag:5];
    self.popupCancel = (UIButton *)[page3.view viewWithTag:6];
    self.popuptitle = (UILabel *)[page3.view viewWithTag:7];
    
    UIButton *privacyButton = (UIButton *)[page3.view viewWithTag:8];
    if(privacyButton) {
        [privacyButton addTarget:self action:@selector(privacyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *FacebookButton = (UIButton *)[page4.view viewWithTag:1];
    if(FacebookButton) {
        [FacebookButton addTarget:self action:@selector(FacebookTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *TwitterButton = (UIButton *)[page4.view viewWithTag:2];
    if(TwitterButton) {
        [TwitterButton addTarget:self action:@selector(TwitterTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *notAuthButton = (UIButton *)[page4.view viewWithTag:3];
    if(notAuthButton) {
        [notAuthButton addTarget:self action:@selector(unAuthTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // load the view controllers in our pages array
    self.pages = [[NSArray alloc] initWithObjects:page1, page2, page3, page4, nil];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    [self.pageController setDelegate:self];
    [self.pageController setDataSource:self];
    
    [[self.pageController view] setFrame:[[self view] bounds]];
    NSArray *viewControllers = [NSArray arrayWithObject:[self.pages objectAtIndex:0]];
    [self.pageControl setCurrentPage:0];
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    
    [self.view addSubview:self.pageControl];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    [self.view sendSubviewToBack:[self.pageController view]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];    // get the index of the current view controller on display
    [self.pageControl setCurrentPage:self.pageControl.currentPage+1];   // move the pageControl indicator to the next page
    
        // return the next view controller
        if(currentIndex==2 && [self.username.text length] == 0){
            return  nil;
        }
    
       // check if we are at the end and decide if we need to present the next viewcontroller
       if ( currentIndex < [self.pages count]-1) {
        return [self.pages objectAtIndex:currentIndex+1];
    }
        //if failure return nil else return return [self.pages objectAtIndex:currentIndex+1];
    else {
        return nil;                                                         // do nothing
    }
}


- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    
    NSUInteger currentIndex = [self.pages indexOfObject:viewController];    // get the index of the current view controller on display
    [self.pageControl setCurrentPage:self.pageControl.currentPage-1];                   // move the pageControl indicator to the next page
    
    // check if we are at the beginning and decide if we need to present the previous viewcontroller
    if ( currentIndex > 0) {
        return [self.pages objectAtIndex:currentIndex-1];                   // return the previous viewcontroller
    } else {
        return nil;                                                         // do nothing
    }
}

- (void)changePage:(id)sender {
    
    UIViewController *visibleViewController = self.pageController.viewControllers[0];
    NSUInteger currentIndex = [self.pages indexOfObject:visibleViewController];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self.pages objectAtIndex:self.pageControl.currentPage]];
    
    if (self.pageControl.currentPage > currentIndex) {
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else {
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        
    }
}


///////page3



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

///////page4




- (void)FacebookTapped:(id)sender{
    
    
    if  ([self.username.text length] == 0)
    {
        NSLog(@"Facebook");
        
        //Facebook Link processing
        
    }else{
        NSString *alertMessage = @"ユーザー名を入力してください";
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alrt show];
    }
}




- (void)TwitterTapped:(id)sender{
    
    if  ([self.username.text length] == 0)
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
    
    if  ([self.username.text length] == 0)
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

-(void)insertUsername:(id)sender{
    NSLog(@"text:%@",self.username.text);
    
    if (self.username.text.length != 0) {
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *os = [@"iOS_" stringByAppendingString:[UIDevice currentDevice].systemVersion];
        
        // execute Signup API
        [APIClient Signup:self.username.text os:os model:[UIDevice currentDevice].model register_id:[ud stringForKey:@"STRING"] handler:^(id result, NSUInteger code, NSError *error)
         {
             
             NSLog(@"register result: %@ error :%@", result, error);
             
             if (!error) {
                 
                 //success
                 if ([result[@"code"] integerValue] == 200) {
                     
                     //save user data
                     NSString* username = [result objectForKey:@"username"];
                     NSString* picture = [result objectForKey:@"profile_img"];
                     NSString* user_id = [result objectForKey:@"user_id"];
                     NSString* identity_id = [result objectForKey:@"identity_id"];
                     NSString* token = [result objectForKey:@"token"];
                     [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"username"];
                     [[NSUserDefaults standardUserDefaults] setValue:picture forKey:@"avatarLink"];
                     [[NSUserDefaults standardUserDefaults] setValue:user_id forKey:@"user_id"];
                     [[NSUserDefaults standardUserDefaults] setValue:identity_id forKey:@"identity_id"];
                     [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"token"];
                     
                     //save badge num
                     int numberOfNewMessages = [[result objectForKey:@"badge_num"] intValue];
                     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                     NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
                     [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
                     UIApplication *application = [UIApplication sharedApplication];
                     application.applicationIconBadgeNumber = numberOfNewMessages;
                     [ud synchronize];
                     
                     
                     //important!! need cognito method Developer Aunthentificated
                     
                     
                     
                 }else if([result[@"code"] integerValue] != 200) {
                     
                     //success
                     UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:@"このユーザー名はすでに使われております" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alrt show];
                     //[self removeFromSuperview];
                     
                     
                 }
                 else {
                     //fail
                     UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:result[@"message"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                     [alrt show];
                 }
             }
             
         }];
        
    }
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
