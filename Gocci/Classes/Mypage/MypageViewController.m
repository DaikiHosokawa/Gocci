//
//  MypageViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa
//  Copyright (c) 2015年 INASE,inc. All rights reserved.

#import "MypageViewController.h"
#import "everyTableViewController.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "FollowListViewController.h"
#import "FolloweeListViewController.h"
#import "CheerListViewController.h"
#import "NotificationViewController.h"
#import "everyBaseNavigationController.h"
#import "TableViewController.h"
//#import "MapViewController.h"
#import "STPopup.h"
#import "Swift.h"
#import "requestGPSPopupViewController.h"

@import QuartzCore;

//define Segue name
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_FOLLOW = @"goFollow";
static NSString * const SEGUE_GO_FOLLOWEE = @"goFollowee";
static NSString * const SEGUE_GO_CHEER = @"goCheer";

@protocol MovieViewDelegate;

@interface MypageViewController ()<CollectionViewControllerDelegate1,MapViewControllerDelegate,TableViewControllerDelegate,CLLocationManagerDelegate>
{
    NSDictionary *header;
    NSDictionary *post;
    NSMutableArray *post1;
    __weak IBOutlet UIButton *editButton;
    __weak IBOutlet UISegmentedControl *segmentControll;
    __weak IBOutlet UIView *changeView;
    UIViewController *currentViewController_;
    NSArray *viewControllers_;
    
    // ロケーションマネージャー
    CLLocationManager* locationManager;
}

@property (nonatomic, copy) NSMutableArray *postid_;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;

@property (weak, nonatomic) IBOutlet UILabel *FollowNum;
@property (weak, nonatomic) IBOutlet UILabel *FolloweeNum;
@property (weak, nonatomic) IBOutlet UILabel *CheerNum;
@property (weak, nonatomic) IBOutlet UIButton *badgeButton;


@end

@implementation MypageViewController

-(void)table:(TableViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}

-(void)table:(TableViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}

-(void)collection:(CollectionViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}

-(void)collection:(CollectionViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}

-(void)map:(MapViewController *)vc postid:(NSString *)postid{
    _postID = postid;
}

-(void)map:(MapViewController *)vc restid:(NSString *)restid{
    _postRestname = restid;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self _fetchProfile];
    [segmentControll setSelectedSegmentIndex:0];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:0.9];
    
    // BBBadgeBarButtonItemオブジェクトの作成
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:self.badgeButton];
    self.barButton.badgeBGColor      = [UIColor whiteColor];
    self.barButton.badgeTextColor    = color_custom;
    self.barButton.badgeOriginX = 10;
    self.barButton.badgeOriginY = 10;
    
    // バッジ内容の設定
   self.barButton.badgeValue =  [NSString stringWithFormat : @"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];// ナビゲーションバーに設定
    
    [self.badgeButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    
    self.navigationItem.backBarButtonItem = backButton;
    
    //set notificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"Notification"
                             object:nil];
    
    editButton.layer.cornerRadius = 10;
    editButton.clipsToBounds = YES;
    
    _FollowNum.userInteractionEnabled = YES;
    _FollowNum.tag = 100;
    _FolloweeNum.userInteractionEnabled = YES;
    _FolloweeNum.tag = 101;
    _CheerNum.userInteractionEnabled = YES;
    _CheerNum.tag = 102;
    
    if(!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    

}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MoviePlayerManager sharedManager] stopMovie];
    [[MoviePlayerManager sharedManager] removeAllPlayers];
    [super viewWillDisappear:animated];
}



- (void)setupViewControllers
{
    UIViewController *firstViewController;
    TableViewController *vc = [[TableViewController  alloc] init];
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
    vc.supervc = self;
    vc.receiveDic = post1;
    vc.delegate = self;
    firstViewController = vc;
    vc.soda = changeView.frame;
    
    UIViewController *secondViewController;
    CollectionViewController *vc2 = [[CollectionViewController alloc] init];
    vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    vc2.supervc = self;
    vc2.receiveDic2 = post1;
    vc2.delegate = self;
    secondViewController = vc2;
    vc2.soda = changeView.frame;
    
    UIViewController *thirdViewController;
    MapViewController *vc3 = [[MapViewController alloc] init];
    vc3.receiveDic3 = post;
    vc3.supervc = self;
    vc3.soda = changeView.frame;
    
    thirdViewController = vc3;
    
    viewControllers_ = @[firstViewController, secondViewController, thirdViewController];
}

- (void)changeSegmentedControlValue
{
    
    [[MoviePlayerManager sharedManager] stopMovie];
    
    if(segmentControll.selectedSegmentIndex == 2){
        //GPS is ON
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self performSegueWithIdentifier:@"goMap" sender:self];
        }
        else {
            switch ([CLLocationManager authorizationStatus]) {
                    
                case kCLAuthorizationStatusNotDetermined:
                case kCLAuthorizationStatusAuthorizedAlways:
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                case kCLAuthorizationStatusDenied:
                case kCLAuthorizationStatusRestricted:
                    NSLog(@"not permitted");
                    [segmentControll setSelectedSegmentIndex:0];
                    requestGPSPopupViewController* rvc = [requestGPSPopupViewController new];
                    [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:rvc];
            }
        }
        
    }else{
        if(currentViewController_){
            [currentViewController_ willMoveToParentViewController:nil];
            [currentViewController_.view removeFromSuperview];
            [currentViewController_ removeFromParentViewController];
        }
        
        UIViewController *nextViewController = viewControllers_[segmentControll.selectedSegmentIndex];
        
        if (!nextViewController) {
            return;
        }
        
        [self addChildViewController:nextViewController];
        nextViewController.view.frame = CGRectMake(changeView.bounds.origin.x, changeView.bounds.origin.y, changeView.bounds.size.width, changeView.bounds.size.height+9);
        [changeView addSubview:nextViewController.view];
        [nextViewController didMoveToParentViewController:self];
        
        currentViewController_ = nextViewController;
    }
}


- (IBAction)changeSegmentValue:(id)sender {
    [self changeSegmentedControlValue];
}

- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {

    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
    self.navigationItem.rightBarButtonItem = self.barButton;
    
}




-(void)barButtonItemPressed:(id)sender{
    
    self.barButton.badgeValue = nil;
    
    if (!self.popover) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
        vc.supervc = self;
        self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    }
    
    [self.popover presentPopoverFromRect:CGRectMake(
                                                    self.badgeButton.accessibilityFrame.origin.x + 15, self.badgeButton.accessibilityFrame.origin.y + 30, self.badgeButton.accessibilityFrame.size.width, self.badgeButton.accessibilityFrame.size.height)
                                  inView:self.badgeButton
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
    {
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
    
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    
    if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
    {
        UserpageViewController  *userVC = segue.destinationViewController;
        userVC.postUsername = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    
    if ([segue.identifier isEqualToString:@"goMap"])
    {
        MapViewController  *mapVC = segue.destinationViewController;
        mapVC.receiveDic3 = post;
    }
    
    if ([segue.identifier isEqualToString:SEGUE_GO_FOLLOW])
    {
        FollowListViewController  *followVC = segue.destinationViewController;
        followVC.userID = Persistent.user_id;
    }
    
    if ([segue.identifier isEqualToString:SEGUE_GO_FOLLOWEE])
    {
        FolloweeListViewController  *followeeVC = segue.destinationViewController;
        followeeVC.userID = Persistent.user_id;
    }
    
    if ([segue.identifier isEqualToString:SEGUE_GO_CHEER])
    {
        CheerListViewController  *cheerVC = segue.destinationViewController;
        cheerVC.userID = Persistent.user_id;
    }
    
}


- (void)_fetchProfile
{
    [APIClient User:Persistent.user_id handler:^(id result, NSUInteger code, NSError *error) {
        
        if (code != 200 || error != nil) {
            return;
        }
        NSLog(@"users result:%@",result);
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        NSArray* items = (NSArray*)[result valueForKey:@"posts"];
        
        for (NSDictionary *post2 in items) {
            [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post2]];
        }
        post1 = tempPosts;
        
        NSDictionary* headerInUserPage = (NSDictionary*)[result valueForKey:@"header"];
        header = headerInUserPage;
        NSDictionary* postInUserPage = (NSDictionary*)[result valueForKey:@"posts"];
        post = postInUserPage;
        
        [self byoga];
        [self setupViewControllers];
        [self changeSegmentedControlValue];
    }];
}


-(void)byoga{
    self.profilename.text = [header objectForKey:@"username"];
    [self.profilepicture setImageWithURL:[NSURL URLWithString:[header objectForKey:@"profile_img"]]
                        placeholderImage:[UIImage imageNamed:@"default.png"]];
    self.FolloweeNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follower_num"]];
    self.FollowNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follow_num"]];
    self.CheerNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"cheer_num"]];
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


- (void)showPopupWithTransitionStyle:(STPopupTransitionStyle)transitionStyle rootViewController:(UIViewController *)rootViewController
{
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:rootViewController];
    popupController.cornerRadius = 4;
    popupController.transitionStyle = transitionStyle;
    [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:17] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

@end