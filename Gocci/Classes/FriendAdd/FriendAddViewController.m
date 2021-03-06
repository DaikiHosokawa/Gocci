//
//  TimelinePageMenuViewController.m
//  Gocci
//
//  Created by INASE on 2015/06/18.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "FriendAddViewController.h"

#import "CAPSPageMenu.h"

@interface FriendAddViewController ()
{
}

@property (nonatomic) CAPSPageMenu *pageMenu;

//ページメニューを載せるビュー
@property (weak, nonatomic) IBOutlet UIView *viewBasePageMenu;

@end

@implementation FriendAddViewController

#pragma mark - ALlTimelneTableViewControllerDelegate
/*
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
 */

#pragma mark - ViewLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
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
    
    
    //PageMenu登録
    AddressController *controller1 = [[AddressController alloc] initWithNibName:nil bundle:nil];
    controller1.title = @"連絡先";
    controller1.delegate = self;
    
    FacebookController *controller2 = [[FacebookController alloc] initWithNibName:nil bundle:nil];
    controller2.title = @"Facebook";
    controller2.delegate = self;
    
    TwitterController *controller3 = [[TwitterController alloc] initWithNibName:nil bundle:nil];
    controller3.title = @"Twitter";
    controller3.delegate = self;
    
    DetailController *controller4 = [[DetailController alloc] initWithNibName:nil bundle:nil];
    controller4.title = @"その他";
    controller4.delegate = self;
    
    //PageMenuアイテム
    CGRect rect_screen = [UIScreen mainScreen].bounds;
    NSArray *controllerArray = @[controller1, controller2, controller3, controller4];
    NSInteger count_item = 4;	//画面数
    // !!!:高さは画面高さの10%
    CGFloat height_item = rect_screen.size.height * 0.1; //40.f;	//高さ
    CGFloat width_item = self.view.frame.size.width / count_item; //幅
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionSelectionIndicatorHeight :@(3.0),	//選択マーク高さ default = 3.0
                                 //CAPSPageMenuOptionMenuItemSeparatorWidth : @(0.5),		//アイテム間隔 default = 0.5
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor grayColor],	//メニュー背景色
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
    CGRect rect_pagemenu = CGRectMake(0, 0, self.viewBasePageMenu.frame.size.width, self.viewBasePageMenu.frame.size.height+30);
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray
                                                        frame:rect_pagemenu
                                                      options:parameters];
    
    //サブビューとして追加
    [self.viewBasePageMenu addSubview:_pageMenu.view];
    
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
@end
