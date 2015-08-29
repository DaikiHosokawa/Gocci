//
//  TutorialPageViewController.m
//  Gocci
//
//  Created by Castela on 2015/08/28.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "TutorialPageViewController.h"

@interface TutorialPageViewController (){
    NSArray *pages;
}

@property (retain, nonatomic) NSArray *pages;
@property (strong, nonatomic) UIPageViewController *pageController;

@end

@implementation TutorialPageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    // instantiate the view controlles from the storyboard
    UIViewController *page1 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page1"];
    
    UIViewController *page2 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page2"];
    
    UIViewController *page3 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page3"];
    
    UIViewController *page4 = [[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"page4"];
    
    self.usernameField = (UITextField *)[page3.view viewWithTag:1];
    if(self.usernameField) {
        [self.usernameField addTarget:self action:@selector(insertUsername:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    
    UIButton *ruleButton = (UIButton *)[page3.view viewWithTag:2];
    if(ruleButton) {
        [ruleButton addTarget:self action:@selector(ruleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.popupView = (UIView *)[page3.view viewWithTag:4];
    self.popupWebView = (UIWebView *)[page3.view viewWithTag:5];
    self.popupCancel = (UIButton *)[page3.view viewWithTag:6];
    self.popuptitle = (UILabel *)[page3.view viewWithTag:7];
    
    UIButton *privacyButton = (UIButton *)[page3.view viewWithTag:3];
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
    [self.pageControl setCurrentPage:self.pageControl.currentPage+1];                   // move the pageControl indicator to the next page
    
    // check if we are at the end and decide if we need to present the next viewcontroller
    if ( currentIndex < [self.pages count]-1) {
        return [self.pages objectAtIndex:currentIndex+1];
        // return the next view controller
    
        //check currentIndex==2 && username == nil → can't go index 3
        //if failure return nil else return return [self.pages objectAtIndex:currentIndex+1];
    } else {
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

- (void)insertUsername:(id)sender
{
    [sender resignFirstResponder];
    NSLog(@"text:%@",self.usernameField.text);
    
    if (self.usernameField.text.length == 0) {
        
        // Signup processing
        
    }
}




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
    if  (self.usernameField.text.length != 0)
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
    if  (self.usernameField.text.length != 0)
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
    if  (self.usernameField.text.length != 0)
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
