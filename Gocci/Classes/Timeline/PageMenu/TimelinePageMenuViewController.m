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



static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";


@interface TimelinePageMenuViewController ()
{
    //commentへの引き継ぎ
    NSString *_postID;
    
    //profile_otherへの引き継ぎ
    NSString *_postUsername;
    
    //restnameへの引き継ぎ
    NSString *_postRestname;
    
}
@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) WYPopoverController *popover;
@property (nonatomic) CAPSPageMenu *pageMenu;

//ページメニューを載せるビュー
@property (weak, nonatomic) IBOutlet UIView *viewBasePageMenu;

@end

@implementation TimelinePageMenuViewController

#pragma mark - ALlTimelneTableViewControllerDelegate
-(void)allTimeline:(AllTimelineTableViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}
-(void)allTimeline:(AllTimelineTableViewController *)vc username:(NSString *)user_id
{
    _postUsername = user_id;
}
-(void)allTimeline:(AllTimelineTableViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}

#pragma mark - FollowTableViewController
-(void)follow:(FollowTableViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}
-(void)follow:(FollowTableViewController *)vc username:(NSString *)user_id
{
    _postUsername = user_id;
}
-(void)follow:(FollowTableViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}

#pragma mark - ViewLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //右ナビゲーションアイテム(通知)の実装
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [customButton setImage:[UIImage imageNamed:@"bell"] forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // BBBadgeBarButtonItemオブジェクトの作成
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    
    self.barButton.badgeBGColor      = [UIColor whiteColor];
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    self.barButton.badgeTextColor    = color_custom;
    self.barButton.badgeOriginX = 10;
    self.barButton.badgeOriginY = 10;
    
    // バッジ内容の設定
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
    
    CGRect frame = CGRectMake(0, 0, 500, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"Gocci";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    //ナビゲーションバーに画像
    {
        //タイトル画像設定
        //CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
        //CGFloat width_image = height_image;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView = navigationTitle;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    //set notificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"HogeNotification"
                             object:nil];
    
    //PageMenu登録
    AllTimelineTableViewController *controller1 = [[AllTimelineTableViewController alloc] initWithNibName:nil bundle:nil];
    controller1.title = @"全体";
    controller1.delegate = self;
    
    FollowTableViewController *controller2 = [[FollowTableViewController alloc] initWithNibName:nil bundle:nil];
    controller2.title = @"人気";
    controller2.delegate = self;
    
    //PageMenuアイテム
    CGRect rect_screen = [UIScreen mainScreen].bounds;
    NSArray *controllerArray = @[controller1, controller2, /*controller3, controller4*/];
    NSInteger count_item = 2;	//画面数
    // !!!:高さは画面高さの10%
    CGFloat height_item = rect_screen.size.height * 0.08; //40.f;	//高さ
    CGFloat width_item = self.view.frame.size.width / count_item; //幅
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionSelectionIndicatorHeight :@(3.0),	//選択マーク高さ default = 3.0
                                 //CAPSPageMenuOptionMenuItemSeparatorWidth : @(0.5),		//アイテム間隔 default = 0.5
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: color_custom,	//メニュー背景色
                                 CAPSPageMenuOptionViewBackgroundColor : [UIColor whiteColor],	//サブビュー色
                                 CAPSPageMenuOptionBottomMenuHairlineColor : [UIColor lightGrayColor],	//アンダーライン色
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor whiteColor],	//選択マーク色
                                 //CAPSPageMenuOptionMenuItemSeparatorColor : [UIColor redColor],	// !!!:未使用
                                 //CAPSPageMenuOptionMenuMargin : @(15.f),	// ???:default = 15.f
                                 CAPSPageMenuOptionMenuHeight : @(height_item),	//メニュー高さ
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor : [UIColor whiteColor],	//選択時文字色
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor : [UIColor whiteColor],	//非選択文字色
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl : @(YES),	//YES=スクロールしないメニュー
                                 CAPSPageMenuOptionMenuItemSeparatorRoundEdges : @(NO),	//角に丸みを付けるか？
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],	//タイトルフォント
                                 //CAPSPageMenuOptionMenuItemSeparatorPercentageHeight : @(0.2),	// ???:default = 0.2
                                 CAPSPageMenuOptionMenuItemWidth : @(width_item),	//アイテム幅
                                 //CAPSPageMenuOptionEnableHorizontalBounce : @(YES), // ???:default = YES
                                 //CAPSPageMenuOptionAddBottomMenuHairline : @(YES),	// ???:default = YES
                                 //CAPSPageMenuOptionMenuItemWidthBasedOnTitleTextWidth : @(NO),	// ???:default = NO
                                 CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap : @(250),	//アニメーション時間[ms] default = 500
                                 CAPSPageMenuOptionCenterMenuItems : @(YES),	//選択マークを中央に
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
    
}

#pragma mark - NavigationBarItemAction
-(void)barButtonItemPressed:(id)sender
{
    NSLog(@"badge touched");
    
    self.barButton.badgeValue = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud removeObjectForKey:@"numberOfNewMessages"];
    
    if (!self.popover) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
        vc.supervc = self;
        self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    }
    NSLog(@"%f",self.barButton.accessibilityFrame.size.width);
    [self.popover presentPopoverFromRect:CGRectMake(
                                                    self.barButton.accessibilityFrame.origin.x + 15,
                                                    self.barButton.accessibilityFrame.origin.y + 30,
                                                    self.barButton.accessibilityFrame.size.width,
                                                    self.barButton.accessibilityFrame.size.height)
                                  inView:self.barButton.customView
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
}

#pragma mark - Notification
- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark viewAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark viewDisappear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 遷移前準備
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
    {
        //ここでパラメータを渡す
        everyBaseNavigationController *eveNC = segue.destinationViewController;
        everyTableViewController *eveVC = (everyTableViewController*)[eveNC rootViewController];
        eveVC.postID = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    else
        if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
        {
            //ここでパラメータを渡す
            usersTableViewController_other  *user_otherVC = segue.destinationViewController;
            user_otherVC.postUsername = _postUsername;
        }
        else
            //店舗画面にパラメータを渡して遷移する
            if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
            {
                //ここでパラメータを渡す
                RestaurantTableViewController  *restVC = segue.destinationViewController;
                restVC.postRestName = _postRestname;
            }
}

@end
