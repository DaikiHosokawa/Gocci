//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "UsersViewController.h"
#import "everyTableViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "FollowListViewController.h"
#import "FolloweeListViewController.h"
#import "CheerListViewController.h"
#import "TimelineCell.h"
#import "NotificationViewController.h"

#import "STCustomCollectionViewCell.h"

@import QuartzCore;

#import "everyBaseNavigationController.h"
#import "CollectionViewController.h"
#import "TableViewController.h"
#import "MapViewController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_FOLLOW = @"goFollow";
static NSString * const SEGUE_GO_FOLLOWEE = @"goFollowee";
static NSString * const SEGUE_GO_CHEER = @"goCheer";

@protocol MovieViewDelegate;

@interface UsersViewController ()
{
    NSDictionary *header;
    NSDictionary *post;
    __weak IBOutlet UIButton *editButton;
    __strong NSMutableArray *_items;
    __weak IBOutlet UISegmentedControl *segmentControll;
    __weak IBOutlet UIView *changeView;
    UIViewController *currentViewController_;
    NSArray *viewControllers_;
}

@property (nonatomic, copy) NSMutableArray *postid_;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;

@property (weak, nonatomic) IBOutlet UILabel *FollowNum;
@property (weak, nonatomic) IBOutlet UILabel *FolloweeNum;
@property (weak, nonatomic) IBOutlet UILabel *CheerNum;

@end

@implementation UsersViewController


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    [self _fetchProfile];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //navigationbar
    {
        //タイトル画像設定
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    
    //badge button
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [customButton setImage:[UIImage imageNamed:@"ic_notifications_active_white"] forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    
    self.barButton.badgeBGColor      = [UIColor whiteColor];
    UIColor *color_custom = [UIColor colorWithRed:236./255. green:55./255. blue:54./255. alpha:1.];
    self.barButton.badgeTextColor    = color_custom;
    self.barButton.badgeOriginX = 10;
    self.barButton.badgeOriginY = 10;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    
    //setting button
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [settingBtn setImage:[UIImage imageNamed:@"ic_settings_white"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(eventSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton2 = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:settingBtn];
    
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:self.barButton, barButton2, nil];
    
    //userAddButton
    UIButton *userAddBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [userAddBtn setImage:[UIImage imageNamed:@"ic_person_add_white"] forState:UIControlStateNormal];
    [userAddBtn addTarget:self action:@selector(eventUserAddBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton3 = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:userAddBtn];
    self.navigationItem.leftBarButtonItem = barButton3;
    
    //BackButton
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    
    self.navigationItem.backBarButtonItem = backButton;
    self.parentViewController.view.backgroundColor = [UIColor redColor];
    
    //editButton
    editButton.layer.cornerRadius = 10; // this value vary as per your desire
    editButton.clipsToBounds = YES;
    
    //segmentControll
   // [segmentControll setFrame:CGRectMake(-6, 137, 387, 40)];
    
    //set notificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"HogeNotification"
                             object:nil];
    _FollowNum.userInteractionEnabled = YES;
    _FollowNum.tag = 100;
    _FolloweeNum.userInteractionEnabled = YES;
    _FolloweeNum.tag = 101;
    _CheerNum.userInteractionEnabled = YES;
    _CheerNum.tag = 102;
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    [super viewWillDisappear:animated];
}



//segmentcontroll
- (void)setupViewControllers
{
    UIViewController *firstViewController;
    TableViewController *vc = [[TableViewController  alloc] init];
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
    vc.supervc = self;
    vc.receiveDic = post;
    firstViewController = vc;
    
    UIViewController *secondViewController;
    CollectionViewController *vc2 = [[CollectionViewController alloc] init];
    vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    vc2.supervc = self;
    vc2.receiveDic2 = post;
    secondViewController = vc2;
    
    UIViewController *thirdViewController;
    MapViewController *vc3 = [[MapViewController alloc] init];
    vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    vc3.receiveDic3 = post;
    NSLog(@"ここでは:%@",post);
    vc3.supervc = self;

    thirdViewController = vc3;
   
    viewControllers_ = @[firstViewController, secondViewController, thirdViewController];
}

- (void)changeSegmentedControlValue
{
    if(currentViewController_){
        [currentViewController_ willMoveToParentViewController:nil];
        [currentViewController_.view removeFromSuperview];
        [currentViewController_ removeFromParentViewController];
    }
    
    UIViewController *nextViewController = viewControllers_[segmentControll.selectedSegmentIndex];
    
    [self addChildViewController:nextViewController];
    nextViewController.view.frame = CGRectMake(changeView.bounds.origin.x, changeView.bounds.origin.y, changeView.bounds.size.width, changeView.bounds.size.height-60);
    [changeView addSubview:nextViewController.view];
    [nextViewController didMoveToParentViewController:self];
    
    currentViewController_ = nextViewController;
    
}


//notification

- (IBAction)changeSegmentValue:(id)sender {
    [self changeSegmentedControlValue];
}

- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
    
}

-(void)barButtonItemPressed:(id)sender{
    
    self.barButton.badgeValue = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud removeObjectForKey:@"numberOfNewMessages"];
    
    NSLog(@"badge touched");
    if (!self.popover) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
        vc.supervc = self;
        self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    }
    NSLog(@"%f",self.barButton.accessibilityFrame.size.width);
    [self.popover presentPopoverFromRect:CGRectMake(
                                                    self.barButton.accessibilityFrame.origin.x + 15, self.barButton.accessibilityFrame.origin.y + 30, self.barButton.accessibilityFrame.size.width, self.barButton.accessibilityFrame.size.height)
                                  inView:self.barButton.customView
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
}



#pragma mark - Action


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


#pragma mark - Private Methods


#pragma mark - Segue
#pragma mark 遷移前準備
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //2つ目の画面にパラメータを渡して遷移する
    // !!!:dezamisystem
    //    if ([segue.identifier isEqualToString:@"showDetail2"])
    if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
    {
        //ここでパラメータを渡す
#if 0
        everyTableViewController *eveVC = segue.destinationViewController;
#else
        everyBaseNavigationController *eveNC = segue.destinationViewController;
        everyTableViewController *eveVC = (everyTableViewController*)[eveNC rootViewController];
        [self.popover dismissPopoverAnimated:YES];
#endif
        eveVC.postID = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    //店舗画面にパラメータを渡して遷移する
    // !!!:dezamisystem
    //    if ([segue.identifier isEqualToString:@"goRestpage"])
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    
}


- (void)_fetchProfile
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
     [APIClient User:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
         NSLog(@"叩かれてるよ");
         
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        NSLog(@"users result:%@",result);
        
        NSDictionary* headerDic = (NSDictionary*)[result valueForKey:@"header"];
        NSDictionary* postDic = (NSDictionary*)[result valueForKey:@"posts"];
        header = headerDic;
        post = postDic;
        [self byoga];
         [self setupViewControllers];
         [self changeSegmentedControlValue];
    }];
}


-(void)byoga{
    
    //AppDelegate* profiledelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.profilename.text = [header objectForKey:@"username"];
    [self.profilepicture setImageWithURL:[NSURL URLWithString:[header objectForKey:@"profile_img"]]
                        placeholderImage:[UIImage imageNamed:@"default.png"]];
    self.FolloweeNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follower_num"]];
    self.FollowNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follow_num"]];
    //[header objectForKey:@"follow_num"];
    self.CheerNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"cheer_num"]];
    //[header objectForKey:@"cheer_num"];

}

-(void)eventSettingBtn{
    [self performSegueWithIdentifier:@"goSetting" sender:self];
}

-(void)eventUserAddBtn{
    [self performSegueWithIdentifier:@"goUserAdd" sender:self];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ( touch.view.tag == _FollowNum.tag ){
    [self performSegueWithIdentifier:@"goFollow" sender:self];
    }
    else if ( touch.view.tag == _FolloweeNum.tag ){
    [self performSegueWithIdentifier:@"goFollowee" sender:self];
    }
    else if ( touch.view.tag == _CheerNum.tag){
     [self performSegueWithIdentifier:@"goCheer" sender:self];
    }
}

@end