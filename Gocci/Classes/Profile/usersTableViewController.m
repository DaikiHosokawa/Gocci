//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController.h"
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

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_FOLLOW = @"goFollow";
static NSString * const SEGUE_GO_FOLLOWEE = @"goFollowee";
static NSString * const SEGUE_GO_CHEER = @"goCheer";

@protocol MovieViewDelegate;

@interface usersTableViewController ()
<TimelineCellDelegate>
{
    NSDictionary *header;
    NSMutableArray *thumb;
    /*
     IBOutlet __weak UICollectionView *_collectionView;
     */
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
@property (nonatomic, strong) UIRefreshControl *refresh;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation usersTableViewController

#pragma mark - アイテム名登録用

- (void)setupViewControllers
{
    UIViewController *firstViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
    UIViewController *secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    viewControllers_ = @[firstViewController, secondViewController];
}

- (void)changeSegmentedControlValue
{
    if(currentViewController_){
        NSLog(@"今のビューコンあり");
        [currentViewController_ willMoveToParentViewController:nil];
        [currentViewController_.view removeFromSuperview];
        [currentViewController_ removeFromParentViewController];
    }
    
    UIViewController *nextViewController = viewControllers_[segmentControll.selectedSegmentIndex];
    
    [self addChildViewController:nextViewController];
    nextViewController.view.frame = changeView.bounds;
    [changeView addSubview:nextViewController.view];
    [nextViewController didMoveToParentViewController:self];
    
    currentViewController_ = nextViewController;
}

- (IBAction)changeSegmentValue:(id)sender {
    [self changeSegmentedControlValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewControllers];
    
    [self changeSegmentedControlValue];
    
    //ナビゲーションバーに画像
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
    
    
    //右ナビゲーションアイテム(通知)の実装
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [customButton setImage:[UIImage imageNamed:@"bell"] forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // BBBadgeBarButtonItemオブジェクトの作成
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    
    self.barButton.badgeBGColor      = [UIColor whiteColor];
    UIColor *color_custom = [UIColor colorWithRed:236./255. green:55./255. blue:54./255. alpha:1.];
    self.barButton.badgeTextColor    = color_custom;
    self.barButton.badgeOriginX = 10;
    self.barButton.badgeOriginY = 10;
    
    // バッジ内容の設定
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    self.parentViewController.view.backgroundColor = [UIColor redColor];
    
    editButton.layer.cornerRadius = 10; // this value vary as per your desire
    editButton.clipsToBounds = YES;
    
    [segmentControll setFrame:CGRectMake(-6, 137, 387, 40)];
    /*
     // Table View の設定
     self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
     self.tableView.bounces = YES;
     self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     [self.tableView registerNib:[UINib nibWithNibName:@"TimelineCell" bundle:nil]
     forCellReuseIdentifier:TimelineCellIdentifier];
     
     // Pull to refresh
     self.refresh = [UIRefreshControl new];
     [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
     [self.tableView addSubview:self.refresh];
     */
    
    //set notificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"HogeNotification"
                             object:nil];
    
    /* collec
     UINib *nib = [UINib nibWithNibName:@"STCustomCollectionViewCell" bundle:nil];
     [_collectionView registerNib:nib forCellWithReuseIdentifier:@"CellId"];
     _collectionView.dataSource = self;
     _collectionView.delegate = self;
     */
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


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    // !!!:dezamisystem
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    
    // 動画データを一度全て削除
    //[[MoviePlayerManager sharedManager] removeAllPlayers];
    
    
    [super viewWillDisappear:animated];
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



-(void)byoga{
    //AppDelegate* profiledelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.profilename.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    [self.profilepicture setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatarLink"]]
                        placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    [SVProgressHUD dismiss];
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

/* collec
 - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
 {
 NSLog(@"数:%lu",(unsigned long)[thumb count]);
 return [thumb count];
 }
 
 - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
 {
 STCustomCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
 
 
 [cell.thumb sd_setImageWithURL:[NSURL URLWithString:thumb[indexPath.row]]
 placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
 return cell;
 }
 
 #pragma mark - UICollectionViewDelegate
 
 - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
 {
 NSLog(@"選んだのは:%@",_postid_[indexPath.row]);
 [self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:_postid_[indexPath.row]];
 
 }
 */

@end
