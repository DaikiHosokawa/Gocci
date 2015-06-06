//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "LifelogSubTableViewController.h"
#import "LifelogCell.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "TimelineCell.h"
#import "MoviePlayerManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "everyTableViewController.h"
#import "RestaurantTableViewController.h"
#import "Reachability.h"
#import "NotificationViewController.h"

@import QuartzCore;

#import "everyBaseNavigationController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";


@protocol MovieViewDelegate;

@interface LifelogSubTableViewController()
<TimelineCellDelegate>

- (void)showDefaultContentView;

@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, retain) NSIndexPath *nowindexPath;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation LifelogSubTableViewController

#pragma mark - アイテム名登録用
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //		// !!!:dezamisystem・アイテム名
        //		[self setTitle:@"アカウント"];
        //		// タブバーアイコン
        //		UIImage *icon_normal = [UIImage imageNamed:@"tabbaritem_profile.png"];
        //		UIImage *icon_selected = [UIImage imageNamed:@"tabbaritem_profile_sel.png"];
        //		[self.tabBarItem setFinishedSelectedImage:icon_selected withFinishedUnselectedImage:icon_normal];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

    
    //ナビゲーションバーに画像
    {
        //タイトル画像設定
        CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
        CGFloat width_image = height_image;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
        
    }

    // Table View の設定
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineCell" bundle:nil]
         forCellReuseIdentifier:TimelineCellIdentifier];
    
    //set notificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"HogeNotification"
                             object:nil];


}

- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // !!!:dezamisystem
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    [self _fetchLifelog];
    [self.tableView reloadData];
    
    [SVProgressHUD dismiss];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    [[MoviePlayerManager sharedManager] removeAllPlayers];
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.posts count];
}

//1セルあたりの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TimelineCell cellHeightWithTimelinePost:self.posts[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = TimelineCellIdentifier;
    TimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [TimelineCell cell];
    }
    
    // セルにデータを反映
    TimelinePost *post = self.posts[indexPath.row];
    [cell configureWithTimelinePost:post];
    cell.delegate = self;
    cell.ViolateView.hidden = YES;
    
    // 動画の読み込み
    LOG(@"読み込み完了");
    __weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL f){}];
     [SVProgressHUD dismiss];
    
    return cell ;
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}


#pragma mark - UIScrollView Delegate

//////////////////////////スクロール開始後//////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    // スクロール中は動画を停止する
    // [[MoviePlayerManager sharedManager] scrolling:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // フリック操作によるスクロール終了
    LOG(@"scroll is stoped");
   //[self _playMovieAtCurrentCell];

    NSLog(@"@2");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        // ドラッグ終了 かつ 加速無し
        LOG(@"scroll is stoped");
    [self _playMovieAtCurrentCell];
        NSLog(@"@2");
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // setContentOffset: 等によるスクロール終了
    NSLog(@"scroll is stoped");
    
}


#pragma mark - TimelineCellDelegate
#pragma mark いいねボタンの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
{
    //いいねボタンの時の処理
    LOG(@"postid=%@", postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@", postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/goodinsert/"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                                                       error:&error];
    
    // タイムラインを再読み込み
    //[self _fetchLifelog];
}



#pragma mark rest_nameタップの時の処理
-(void)timelineCell:(TimelineCell *)cell didTapRestaurant:(NSString *)restaurantName locality:(NSString *)locality tel:(NSString *)tel homepage:(NSString *)homepage category:(NSString *)category lon:(NSString *)lon lat:(NSString *)lat total_cheer:(NSString *)total_cheer want_tag:(NSString *)want_tag{
    NSLog(@"restname is touched");
    //rest nameタップの時の処理
    _postRestname = restaurantName;
    _postHomepage = homepage;
    _postLocality = locality;
    _postTell = tel;
    _postCategory = category;
    _postLon = lon;
    _postLat = lat;
    _postTotalCheer = total_cheer;
    _postWanttag = want_tag;
    [self performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:self];
}

#pragma mark コメントボタン押下時の処理
- (void)timelineCell:(TimelineCell *)cell didTapCommentButtonWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    
    [self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
}


#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchLifelog
{
    [SVProgressHUD show];
    
    __weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AppDelegate* lifelogdelegate = [[UIApplication sharedApplication] delegate];
    [APIClient LifelogWithDate:lifelogdelegate.lifelogDate handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        LOG(@"result=%@", result);
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        
        // 取得したデータを self.posts に格納
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *post in result) {
            [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post]];
        }
        
        self.posts = [NSArray arrayWithArray:tempPosts];
        
        // 動画データを一度全て削除
        [[MoviePlayerManager sharedManager] removeAllPlayers];
        
        // 表示の更新
        [weakSelf.tableView reloadData];
        Reachability *curReach2 = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus2 = [curReach2 currentReachabilityStatus];
        
        NSString *alertMessage = @"圏外ですので再生できません。";
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        switch (netStatus2) {
            case NotReachable:  //圏外
                /*圏外のときの処理*/
                [alrt show];
                break;
            case ReachableViaWWAN:  //3G
                
                break;
            case ReachableViaWiFi:
                //WiFi
                
                break;
                
            default:
                
                break;
        }

    }];
}

/*
- (void)timelineCell:(TimelineCell *)cell didTapthumb:(UIImageView *)thumbnailView{
    [self _playMovieAtCurrentCell];
}
 */


/**
 *  現在表示中のセルの動画を再生する
 */
- (void)_playMovieAtCurrentCell
{
    if (self.tabBarController.selectedIndex != 1) {
        // 画面がフォアグラウンドのときのみ再生
        return;
    }
    
    Reachability *curReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    CGFloat currentHeight = 0.0;
    for (NSUInteger i=0; i < [self _currentIndexPath].row; i++) {
        if ([self.posts count] <= i) continue;
        
        currentHeight += [TimelineCell cellHeightWithTimelinePost:self.posts[i]];
    }
    
    TimelineCell *currentCell = [TimelineCell cell];
    [currentCell configureWithTimelinePost:self.posts[[self _currentIndexPath].row]];
    CGRect movieRect = CGRectMake((self.tableView.frame.size.width - currentCell.thumbnailView.frame.size.width) / 2,
                                  currentHeight + currentCell.thumbnailView.frame.origin.y,
                                  currentCell.thumbnailView.frame.size.width,
                                  currentCell.thumbnailView.frame.size.height);
    
    switch (netStatus) {
        case NotReachable:  //圏外
            /*圏外のときの処理*/
            
            break;
        case ReachableViaWWAN:  //3G
            /*3G回線接続のときの処理*/
            [[MoviePlayerManager sharedManager] scrolling:NO];
            [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                          inView:self.tableView
                                                           frame:movieRect];
            
            break;
        case ReachableViaWiFi:  //WiFi
            [[MoviePlayerManager sharedManager] scrolling:NO];
            [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                          inView:self.tableView
                                                           frame:movieRect];
            
            break;
        default:
            [[MoviePlayerManager sharedManager] scrolling:NO];
            [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                          inView:self.tableView
                                                           frame:movieRect];
            
            break;
    }
}

/**
 *  現在表示中のセルを取得
 *
 *  @return
 */
- (TimelineCell *)_currentCell
{
    if ([self.posts count] == 0) {
        return nil;
    }
    
    return (TimelineCell *)[self tableView:self.tableView cellForRowAtIndexPath:[self _currentIndexPath]];
}

/**
 *  現在表示中の indexPath を取得
 *
 *  @return
 */
- (NSIndexPath *)_currentIndexPath
{
    CGPoint point = CGPointMake(self.tableView.contentOffset.x,
                                self.tableView.contentOffset.y + self.tableView.frame.size.height/2);
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point];
    
    return currentIndexPath;
}

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
#endif
        eveVC.postID = _postID;
    }
    //店舗画面にパラメータを渡して遷移する
    // !!!:dezamisystem
    //    if ([segue.identifier isEqualToString:@"goRestpage"])
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
        restVC.postLocality = _postLocality;
        restVC.postHomepage = _postHomepage;
        restVC.postTell = _postTell;
        restVC.postCategory = _postCategory;
        restVC.postLon = _postLon;
        restVC.postLat = _postLat;
        restVC.postTotalCheer = _postTotalCheer;
        restVC.postWanttag = _postWanttag;
    }
    
}

-(void)barButtonItemPressed:(id)sender{
    
    self.barButton.badgeValue = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud removeObjectForKey:@"numberOfNewMessages"];
    
    NSLog(@"badge touched");
    if (!self.popover) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
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


@end
