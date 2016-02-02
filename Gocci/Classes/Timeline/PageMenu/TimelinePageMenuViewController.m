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
#import "MessageViewController.h"

#import "STPopup.h"
#import "SortViewController.h"

#import "TabbarBaseViewController.h"

#import "requestGPSPopupViewController.h"

#import "Swift.h"



static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_HEATMAP = @"goHeatmap";

@interface TimelinePageMenuViewController ()<CLLocationManagerDelegate,CAPSPageMenuDelegate,CLLocationManagerDelegate>
{
    NSString *_postID;
    NSString *_postUsername;
    NSString *_postRestname;
    CLLocationManager* locationManager;
}
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) WYPopoverController *popover;
@property (nonatomic) CAPSPageMenu *pageMenu;

@property (strong, nonatomic) RequestGPSViewController *requestGPSViewController;



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

#pragma mark - FollowViewController
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

#pragma mark - NearViewController
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

#pragma mark - GochiViewController
-(void)gochi:(GochiViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}
-(void)gochi:(GochiViewController *)vc username:(NSString *)user_id
{
    _postUsername = user_id;
}
-(void)gochi:(GochiViewController *)vc rest_id:(NSString *)rest_id
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
    
    
         UIImage *img = [UIImage imageNamed:@"ic_location_on_white.png"];
         UIButton *heatMapBtn = [[UIButton alloc]
         initWithFrame:CGRectMake(0, 0, 30, 30)];
         [heatMapBtn setBackgroundImage:img forState:UIControlStateNormal];
         
         
         [heatMapBtn addTarget:self
         action:@selector(goHeatmap) forControlEvents:UIControlEventTouchUpInside];
         
    
    
    UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
    UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    navigationTitle.image = image;
    
    self.navigationItem.titleView =navigationTitle;
    
    UIButton *notificationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [notificationBtn setImage:[UIImage imageNamed:@"ic_notifications_active_white"] forState:UIControlStateNormal];
    [notificationBtn addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:notificationBtn];
    
    self.barButton.badgeBGColor      = [UIColor whiteColor];
    self.barButton.badgeTextColor    = color_custom;
    self.barButton.badgeOriginX = 10;
    self.barButton.badgeOriginY = 10;
    
    self.barButton.badgeValue =  [NSString stringWithFormat : @"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"Notification"
                             object:nil];
    
    
    UIButton *sortBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [sortBtn setImage:[UIImage imageNamed:@"ic_sort_white"] forState:UIControlStateNormal];
    [sortBtn addTarget:self action:@selector(SortLaunch) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *sortBtnNavi = [[UIBarButtonItem alloc] initWithCustomView:sortBtn];
    
    if(!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    
    //self.navigationItem.rightBarButtonItem = self.barButton;
    self.navigationItem.leftBarButtonItem = sortBtnNavi;
    
    BBBadgeBarButtonItem *heatMapBtnBBB = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:heatMapBtn];
    
    NSArray *right = [NSArray arrayWithObjects: self.barButton, heatMapBtnBBB, nil];
    
    self.navigationItem.rightBarButtonItems = right;
    
    [self setupPageMenu:0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrolling");
}


- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
    
    // ナビゲーションバーに設定する
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[[UIApplication sharedApplication] applicationIconBadgeNumber] ];
    self.navigationItem.rightBarButtonItem = self.barButton;
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

-(void)setupPageMenu:(int)page
{
    self.recoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecoViewController"];
    self.recoViewController.title = @"最新";
    self.recoViewController.delegate = self;
    
    self.nearViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NearViewController"];
    self.nearViewController.title = @"近く";
    self.nearViewController.delegate = self;
    
    self.requestGPSViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RequestGPSViewController"];
    self.requestGPSViewController.title = @"近く";
    self.requestGPSViewController.delegate = self;
    
    self.followViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowViewController"];
    self.followViewController.title = @"フォロー";
    self.followViewController.delegate = self;
    
    self.gochiViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GochiViewController"];
    self.gochiViewController.title = @"お気に入り";
    self.gochiViewController.delegate = self;
    
    if(!locationManager){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    
    NSArray *controllerArray;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {controllerArray = @[self.recoViewController, self.nearViewController, self.followViewController,self.gochiViewController];
        
    }
    else {
        switch ([CLLocationManager authorizationStatus]) {
                
            case kCLAuthorizationStatusNotDetermined:
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                NSLog(@"not permitted");
                controllerArray = @[self.recoViewController, self.requestGPSViewController, self.followViewController,self.gochiViewController];
                
                
        }
    }
    
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:0.9];
    
    NSInteger count_item = 3;
    CGFloat width_item = [UIScreen mainScreen].bounds.size.width / count_item;
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
    
    if (page != 0) {
        [_pageMenu moveToPage:page];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MoviePlayerManager sharedManager] stopMovie];
     [[MoviePlayerManager sharedManager] removeAllPlayers];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
    {
        everyBaseNavigationController *meNC = segue.destinationViewController;
        MessageViewController *meVC = (MessageViewController*)[meNC rootViewController];
        meVC.postID = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    else if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
    {
        UserpageViewController  *userVC = segue.destinationViewController;
        userVC.postUsername = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    else if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    else if ([segue.identifier isEqualToString:SEGUE_GO_HEATMAP])
    {
        ClusterMapViewController *clusterMapVC = segue.destinationViewController;
        clusterMapVC.delegate = self;
    }
    
}

-(void)goHeatmap{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [self performSegueWithIdentifier:SEGUE_GO_HEATMAP sender:nil];
    }
    else {
        
        [_pageMenu moveToPage:1];
        
        
//        switch ([CLLocationManager authorizationStatus]) {
//                
//            case kCLAuthorizationStatusNotDetermined:
//            case kCLAuthorizationStatusAuthorizedAlways:
//            case kCLAuthorizationStatusAuthorizedWhenInUse:
//            case kCLAuthorizationStatusDenied:
//            case kCLAuthorizationStatusRestricted:
//                NSLog(@"not permitted");
//                requestGPSPopupViewController* rvc = [requestGPSPopupViewController new];
//                [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:rvc];
//        }
    }
    
}

-(void)barButtonItemPressed:(id)sender{
    
    self.barButton.badgeValue = nil;
    
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

-(void)handleUserChosenGPSPosition:(CLLocationCoordinate2D)position {

    [_pageMenu moveToPage:1];
    
    [self.nearViewController updateForPosition:position];
    //[self.nearViewController setTitle:@"NOW FROM MAP"];
}



@end








