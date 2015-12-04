//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import "TimelinePageMenuViewController.h"

#import "BBBadgeBarButtonItem.h"
#import "NotificationViewController.h"
#import "WYPopoverController.h"

#import "CAPSPageMenu.h"
#import "everyBaseNavigationController.h"
#import "everyTableViewController.h"

#import "STPopup.h"
#import "SortViewController.h"

#import "TabbarBaseViewController.h"

#import "requestGPSPopupViewController.h"

#import "Swift.h"


static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_HEATMAP = @"goHeatmap";

@interface TimelinePageMenuViewController ()<CLLocationManagerDelegate,CAPSPageMenuDelegate>
{
    NSString *_postID;
    NSString *_postUsername;
    NSString *_postRestname;
    CLLocationManager* locationManager;
}
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) WYPopoverController *popover;
@property (nonatomic) CAPSPageMenu *pageMenu;


@property (weak, nonatomic) IBOutlet UIView *viewBasePageMenu;

@end

@implementation TimelinePageMenuViewController



#pragma mark - ALlTimelneTableViewControllerDelegate
-(void)reco:(RecoViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}
-(void)reco:(RecoViewController *)vc username:(NSString *)user_id
{
    _postUsername = user_id;
}
-(void)reco:(RecoViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}

#pragma mark - FollowTableViewController
-(void)follow:(FollowViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}
-(void)follow:(FollowViewController *)vc username:(NSString *)user_id
{
    _postUsername = user_id;
}
-(void)follow:(FollowViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}

#pragma mark - ALlTimelneTableViewControllerDelegate
-(void)near:(NearViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}
-(void)near:(NearViewController *)vc username:(NSString *)user_id
{
    _postUsername = user_id;
}
-(void)near:(NearViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}

#pragma mark - ViewLoad
- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:0.9];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    UIImage *img = [UIImage imageNamed:@"ic_location_on_white.png"];  // ボタンにする画像を生成する
    UIButton *btn = [[UIButton alloc]
                      initWithFrame:CGRectMake(0, 0, 30, 30)];  // ボタンのサイズを指定する
    [btn setBackgroundImage:img forState:UIControlStateNormal];  // 画像をセットする
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    
    [btn addTarget:self
            action:@selector(goHeatmap) forControlEvents:UIControlEventTouchUpInside];
    
    //右ナビゲーションアイテム(通知)の実装
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [customButton setImage:[UIImage imageNamed:@"ic_notifications_active_white"] forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // BBBadgeBarButtonItemオブジェクトの作成
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    
    self.barButton.badgeBGColor      = [UIColor whiteColor];
    self.barButton.badgeTextColor    = color_custom;
    self.barButton.badgeOriginX = 10;
    self.barButton.badgeOriginY = 10;
    
    // バッジ内容の設定
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する


    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:button1, self.barButton, nil];
    
    RequestGPSViewController *vc0 = [[RequestGPSViewController alloc] init];
    vc0 = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestGPSViewController"];
    vc0.title = @"現在地周辺";
    //vc0.delegate = self;
    self.requestGPSViewController = vc0;
    
    NearViewController *vc1 = [[NearViewController alloc] init];
    vc1 = [self.storyboard instantiateViewControllerWithIdentifier:@"NearViewController"];
    vc1.title = @"現在地周辺";
    vc1.delegate = self;
    self.nearViewController = vc1;
    
    RecoViewController *vc2 = [[RecoViewController alloc] init];
    vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"RecoViewController"];
    vc2.title = @"新着";
    vc2.delegate = self;
    self.recoViewController = vc2;
    
    FollowViewController *vc3 = [[FollowViewController alloc] init];
    vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
    vc3.title = @"フォロー";
    vc3.delegate = self;
    self.followViewController = vc3;
    
    {
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        
        self.navigationItem.titleView =navigationTitle;
    }
    
    
    CGRect rect_screen = [UIScreen mainScreen].bounds;
    
    
    if(!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    NSArray *controllerArray;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {controllerArray = @[vc1,vc2, vc3];
        
    }
    else {
        switch ([CLLocationManager authorizationStatus]) {
                
            case kCLAuthorizationStatusNotDetermined:
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                NSLog(@"not permitted");
                controllerArray = @[vc0,vc2, vc3];
                
                
        }
    }
    
    NSInteger count_item = 3;
    CGFloat width_item = rect_screen.size.width / count_item;
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionSelectionIndicatorHeight :@(2.0),
                                 CAPSPageMenuOptionMenuItemSeparatorWidth : @(4.3),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionViewBackgroundColor : [UIColor whiteColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor :  [UIColor blackColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor:
                                     color_custom,
                                 CAPSPageMenuOptionMenuMargin : @(20.0),
                                 CAPSPageMenuOptionMenuHeight : @(40.0),
                                    CAPSPageMenuOptionSelectedMenuItemLabelColor :color_custom,
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor : [UIColor colorWithRed:40.0/255. green:40.0/255. blue:40.0/255. alpha:1.0],
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl : @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorRoundEdges : @(YES),
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0],                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight : @(0.1),
                                 CAPSPageMenuOptionMenuItemWidth : @(width_item),
                                 CAPSPageMenuOptionAddBottomMenuHairline : @(NO),
                                 CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap : @(250),
                                 };
    
    CGRect rect_pagemenu = CGRectMake(0, 0, self.viewBasePageMenu.frame.size.width, self.viewBasePageMenu.frame.size.height);

    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray
                                                        frame:rect_pagemenu
                                                      options:parameters];
     _pageMenu.delegate = self;
    
    [self.viewBasePageMenu addSubview:_pageMenu.view];
    
    UIImage *image = [UIImage imageNamed:@"sort.png"];
    UIButton *button = [[UIButton alloc]
                     initWithFrame:CGRectMake(self.view.frame.size.width - 72, self.view.frame.size.height - 110, 45,45)];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self
            action:@selector(SortLaunch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}


- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    
    if ([controller conformsToProtocol:@protocol(SortableTimeLineSubView)]) {
        
        self.currentVisibleSortableSubViewController = (UIViewController <SortableTimeLineSubView> *)controller;
        [[MoviePlayerManager sharedManager] stopMovie];
        [[MoviePlayerManager sharedManager] removeAllPlayers];
    }
}

-(void)SortLaunch{
    SortViewController* svc = [SortViewController new];
    svc.timelinePageMenuViewController = self;
    [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:svc];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
    {
        everyBaseNavigationController *eveNC = segue.destinationViewController;
        everyTableViewController *eveVC = (everyTableViewController*)[eveNC rootViewController];
        eveVC.postID = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    else
        if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
        {
            UserpageViewController  *userVC = segue.destinationViewController;
            userVC.postUsername = _postUsername;
        }
        else
            if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
            {
                RestaurantTableViewController  *restVC = segue.destinationViewController;
                restVC.postRestName = _postRestname;
            }
}

-(void)goHeatmap{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [self performSegueWithIdentifier:SEGUE_GO_HEATMAP sender:nil];
    }
    else {
        switch ([CLLocationManager authorizationStatus]) {
                
            case kCLAuthorizationStatusNotDetermined:
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                NSLog(@"not permitted");
                requestGPSPopupViewController* rvc = [requestGPSPopupViewController new];
                [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:rvc];
        }
    }
    
}

-(void)barButtonItemPressed:(id)sender{
    
    self.barButton.badgeValue = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; 
    [ud removeObjectForKey:@"numberOfNewMessages"];
    
    
    if (!self.popover) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
        vc.supervc = self;
        self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    }
    
    [self.popover presentPopoverFromRect:CGRectMake(
                                                    self.barButton.accessibilityFrame.origin.x + 15, self.barButton.accessibilityFrame.origin.y + 30, self.barButton.accessibilityFrame.size.width, self.barButton.accessibilityFrame.size.height)
                                  inView:self.barButton.customView
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
}


@end
