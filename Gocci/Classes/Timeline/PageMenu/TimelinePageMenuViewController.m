//
//  TimelinePageMenuViewController.m
//  Gocci
//
//  Created by INASE on 2015/06/18.
//  Copyright (c) 2015年 Massara. All rights reserved.
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


static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";


@interface TimelinePageMenuViewController ()
{
    NSString *_postID;
    NSString *_postUsername;
    NSString *_postRestname;
    
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
    NSArray *controllerArray = @[vc1,vc2, vc3];
    NSInteger count_item = 3;
    CGFloat width_item = rect_screen.size.width / count_item; //幅
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionSelectionIndicatorHeight :@(2.0),	//選択マーク高さ default = 3.0
                                 CAPSPageMenuOptionMenuItemSeparatorWidth : @(4.3),		//アイテム間隔 default = 0.5
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],	//メニュー背景色
                                 CAPSPageMenuOptionViewBackgroundColor : [UIColor whiteColor],	//サブビュー色
                                 CAPSPageMenuOptionBottomMenuHairlineColor :  [UIColor blackColor],	//アンダーライン色
                                 CAPSPageMenuOptionSelectionIndicatorColor:
                                     color_custom,		//選択マーク色
                                 //CAPSPageMenuOptionMenuItemSeparatorColor : [UIColor redColor],	// !!!:未使用
                                 CAPSPageMenuOptionMenuMargin : @(20.0),	// ???:default = 15.f
                                 CAPSPageMenuOptionMenuHeight : @(40.0),	//メニュー高さ
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor :color_custom,	//選択時文字色
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor : [UIColor colorWithRed:40.0/255. green:40.0/255. blue:40.0/255. alpha:1.0],	//非選択文字色
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl : @(YES),	//YES=スクロールしないメニュー
                                 CAPSPageMenuOptionMenuItemSeparatorRoundEdges : @(YES),	//角に丸みを付けるか？
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0],	//タイトルフォント
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight : @(0.1),	// ???:default = 0.2
                                 CAPSPageMenuOptionMenuItemWidth : @(width_item),	//アイテム幅
                                 //CAPSPageMenuOptionEnableHorizontalBounce : @(YES), // ???:default = YES
                                 CAPSPageMenuOptionAddBottomMenuHairline : @(NO),	// ???:default = YES
                                 //CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth : @(NO),	// ???:default = NO
                                 CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap : @(250),	//アニメーション時間[ms] default = 500
                                 //                               CAPSPageMenuOptionCenterMenuItems : @(YES),	//選択マークを中央に
                                 //CAPSPageMenuOptionHideTopMenuBar : @(NO),//メニューを隠した状態にするか？
                                 };
    
    //PageMenu確保
    // CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
    CGRect rect_pagemenu = CGRectMake(0, 0, self.viewBasePageMenu.frame.size.width, self.viewBasePageMenu.frame.size.height);
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray
                                                        frame:rect_pagemenu
                                                      options:parameters];
    
    //サブビューとして追加
    [self.viewBasePageMenu addSubview:_pageMenu.view];
    
    UIImage *img = [UIImage imageNamed:@"sort.png"];  // ボタンにする画像を生成する
    UIButton *btn = [[UIButton alloc]
                     initWithFrame:CGRectMake(self.view.frame.size.width - 72, self.view.frame.size.height - 110, 45,45)];  // ボタンのサイズを指定する
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    [btn addTarget:self
            action:@selector(SortLaunch) forControlEvents:UIControlEventTouchUpInside];
    
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
            usersTableViewController_other  *user_otherVC = segue.destinationViewController;
            user_otherVC.postUsername = _postUsername;
        }
        else
            if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
            {
                RestaurantTableViewController  *restVC = segue.destinationViewController;
                restVC.postRestName = _postRestname;
            }
}

@end
