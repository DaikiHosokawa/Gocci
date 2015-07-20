//
//  AllTimelineTableViewController.m
//  Gocci
//
//  Created by デザミ on 2015/06/17.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "AllTimelineTableViewController.h"
#import "searchTableViewController.h"
#import "everyTableViewController.h"
#import "TimelineCell.h"
#import "AppDelegate.h"
#import "usersTableViewController.h"
#import "everyBaseNavigationController.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "LocationClient.h"
#import "BBBadgeBarButtonItem.h"
#import "NotificationViewController.h"

#import "TimelinePageMenuViewController.h"

// 遷移
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@import AVFoundation;
@import QuartzCore;

@protocol MovieViewDelegate;

@interface AllTimelineTableViewController()<CLLocationManagerDelegate, TimelineCellDelegate>
@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property (nonatomic, copy) NSMutableArray *postid_;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *notificationText;
@property (nonatomic, strong) UIRefreshControl *refresh;

@property (nonatomic,strong) NSArray *posts;	// タイムラインのデータ

@end

@implementation AllTimelineTableViewController
@synthesize thumbnailView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    // API からタイムラインのデータを取得
    [self _fetchTimelineUsingLocationCacheALL:YES];
    
    
}

//- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
//
//	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
//	self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
//	NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
//	self.navigationItem.rightBarButtonItem = self.barButton;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - viewAppear
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark - viewDisappear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    // 動画データを一度全て削除
    [[MoviePlayerManager sharedManager] removeAllPlayers];
}



#pragma mark - UIRefreshControl Action
- (void)refresh:(UIRefreshControl *)sender
{
    [self _fetchTimelineUsingLocationCacheALL:YES];
}




#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    // スクロール中は動画を停止する
    //  [[MoviePlayerManager sharedManager] scrolling:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //	//一番下までスクロールしたかどうか
    //	if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    //	{
    //		//まだ表示するコンテンツが存在するか判定し存在するなら○件分を取得して表示更新する
    //	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //	// フリック操作によるスクロール終了
    //	LOG(@"scroll is stoped");
    //
    //	// [self _playMovieAtCurrentCell];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        // ドラッグ終了 かつ 加速無し
        LOG(@"scroll is stoped");
        
        [self _playMovieAtCurrentCell];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // setContentOffset: 等によるスクロール終了
    //	NSLog(@"scroll is stoped");
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    return indexPath;
}

- (void)_playMovieAtCurrentCell
{
    /*
     if ( [self.posts count] == 0){
     return;
     }
     */
    
    if (self.tabBarController.selectedIndex != 0) {
        // 画面がフォアグラウンドのときのみ再生
        return;
    }
    
    
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
    
    
    [[MoviePlayerManager sharedManager] scrolling:NO];
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:movieRect];
    
}

//現在表示中の indexPath を取得
- (NSIndexPath *)_currentIndexPath
{
    CGPoint point = CGPointMake(self.tableView.contentOffset.x,
                                self.tableView.contentOffset.y + self.tableView.frame.size.height/2);
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point];
    
    return currentIndexPath;
}

#pragma mark - Table view data source
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
////#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [self.posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TimelineCell cellHeightWithTimelinePost:self.posts[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = TimelineCellIdentifier;
    TimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [TimelineCell cell];
    }
    
    // セルにデータを反映
    TimelinePost *post = self.posts[indexPath.row];
    
    [cell configureWithTimelinePost:post];
    cell.delegate = self;
    
    // 動画の読み込み
    //    __weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL f){}];
    [SVProgressHUD dismiss];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択状態の解除
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - TimelineCellDelegate
#pragma mark いいねボタン押し
- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
{
    
    // API からデータを取得
    [APIClient postGood:postID handler:^(id result, NSUInteger code, NSError *error) {
        LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
    }
     ];
    //[self.view performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:YES];
    //_currentIndexPath
    
    // タイムラインを再読み込み
    // [self _fetchTimeline];
}

- (void)timelineCell:(TimelineCell *)cell didTapViolateButtonWithPostID:(NSString *)postID
{
    //違反報告ボタンの時の処理
    LOG(@"postid=%@", postID);
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class)
    {
        // iOS 8の時の処理
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を違反報告しますか？" preferredStyle:UIAlertControllerStyleAlert];
        
        // addActionした順に左から右にボタンが配置されます
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // API からデータを取得
            [APIClient postViolation:postID handler:^(id result, NSUInteger code, NSError *error) {
                LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
                if (result) {
                    NSString *alertMessage = @"違反報告をしました";
                    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alrt show];
                }
            }
             ];
            
                   }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [APIClient postViolation:postID handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
            if (result) {
                NSString *alertMessage = @"違反報告をしました";
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show];
            }
        }
         ];
    }
    
}

#pragma mark user_nameタップの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserName:(NSString *)userName picture:(NSString *)usersPicture flag:(NSInteger)flag
{
    //user nameタップの時の処理
    LOG(@"username=%@", userName);
    _postUsername = userName;
    _postPicture = usersPicture;
    _postFlag = flag;
    
    LOG(@"postUsername:%@",_postUsername);
    
#if 0
    [self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
#else
    [self.delegate allTimeline:self username:userName picture:usersPicture flag:flag];
    TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
    [vc performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:nil];
#endif
    
    LOG(@"Username is touched");
}

-(void)timelineCell:(TimelineCell *)cell didTapNaviWithLocality:(NSString *)Locality
{
    NSString *mapText = Locality;
    mapText  = [mapText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *directions = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@&zoom=18&directionsmode=walking",mapText];
    NSLog(@"URLSchemes:%@",directions);
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:directions]];
    }
    else {
        NSLog(@"Can't use comgooglemaps://");
        //アラート出す
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ナビゲーション使用にはGoogleMapのアプリが必要です"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark user_nameタップの時の処理 2
- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserPicture:(NSString *)userPicture name:(NSString *)userName flag:(NSInteger)flag
{
    //user nameタップの時の処理 2
    LOG(@"userspicture=%@", userPicture);
    _postPicture = userPicture;
    _postUsername = userName;
    _postFlag = flag;
    
    LOG(@"postUsername:%@",_postUsername);
    
#if 0
    [self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
#else
    [self.delegate allTimeline:self username:userName picture:userPicture flag:flag];
    TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
    [vc performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:nil];
#endif
    
    LOG(@"Username is touched");
    LOG(@"postUsername:%@",_postPicture);
    LOG(@"Username is touched");
}

- (void)timelineCell:(TimelineCell *)cell didTapRestaurant:(NSString *)rest_id
{
    NSLog(@"restname is touched");
    //rest nameタップの時の処理
#if 0
    [self performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:self];
#else
    [self.delegate allTimeline:self rest_id:rest_id];
    TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:nil];
#endif
    
}

- (void)timelineCell:(TimelineCell *)cell didTapCommentButtonWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    
#if 0
    [self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
#else
    [self.delegate allTimeline:self postid:postID];
    TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
    [vc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
#endif
}

/**
 *　全体タイムラインのデータを取得
 *
 *  @param usingLocationCache2 近くの投稿がなかった場合の全体のタイムライン表示
 */
- (void)_fetchTimelineUsingLocationCacheALL:(BOOL)usingLocationCache
{
    
    [SVProgressHUD show];
    
    __weak typeof(self)weakSelf = self;
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [weakSelf.refresh beginRefreshing];
        
        // API からデータを取得
        [APIClient Timeline:^(id result, NSUInteger code, NSError *error)
         {
             LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             
             if ([weakSelf.refresh isRefreshing]) {
                 [weakSelf.refresh endRefreshing];
             }
             
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
             if ([self.posts count]== 0) {
                 NSLog(@"投稿がない");
                 
             }
             
             // 動画データを一度全て削除
             [[MoviePlayerManager sharedManager] removeAllPlayers];
             
             // 表示の更新
             [weakSelf.tableView reloadData];
             [SVProgressHUD dismiss];
             
             //			 BOOL isServerAvailable;
             //			 NSString *alertMessage = @"圏外ですので再生できません。";
             //			 UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             
         }];
    };
    
    // 位置情報キャッシュを使う場合で、位置情報キャッシュが存在する場合、
    // キャッシュされた位置情報を利用して API からデータを取得する
    CLLocation *cachedLocation = [LocationClient sharedClient].cachedLocation;
    if (usingLocationCache && cachedLocation != nil) {
        fetchAPI(cachedLocation.coordinate);
        return;
    }
    
    // 位置情報キャッシュを使わない、あるいはキャッシュが存在しない場合、
    // 位置情報を取得してから API へアクセスする
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         LOG(@"location=%@, error=%@", location, error);
         
         if (error) {
             // 位置情報の取得に失敗
             // TODO: アラート等を掲出
             return;
         }
         
         fetchAPI(location.coordinate);
     }];
    
}

//#pragma mark - Navigation
//#pragma mark 遷移前準備
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//
//
//	if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
//	{
//		//ここでパラメータを渡す
//#if 0
//		everyTableViewController *eveVC = segue.destinationViewController;
//#else
//		everyBaseNavigationController *eveNC = segue.destinationViewController;
//		everyTableViewController *eveVC = (everyTableViewController*)[eveNC rootViewController];
//#endif
//		eveVC.postID = (NSString *)sender;
//	}
//
//	if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
//	{
//		//ここでパラメータを渡す
//		usersTableViewController_other *useVC = segue.destinationViewController;
//		useVC.postUsername = _postUsername;
//		useVC.postPicture = _postPicture;
//		useVC.postFlag = _postFlag;
//	}
//	//店舗画面にパラメータを渡して遷移する
//	//	if ([segue.identifier isEqualToString:@"goRestpage"])
//	if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
//	{
//		//ここでパラメータを渡す
//		RestaurantTableViewController  *restVC = segue.destinationViewController;
//		restVC.postRestName = _postRestname;
//		restVC.postHomepage = _postHomepage;
//		restVC.postLocality = _postLocality;
//		restVC.postCategory = _postCategory;
//		restVC.postLon = _postLon;
//		restVC.postLat = _postLat;
//		restVC.postTell = _postTell;
//		restVC.postTotalCheer = _postTotalCheer;
//		restVC.postWanttag = _postWanttag;
//	}
//
//}
//
@end
