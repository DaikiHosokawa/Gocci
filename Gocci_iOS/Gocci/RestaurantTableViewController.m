//
//  RestaurantTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "RestaurantTableViewController.h"
#import "searchTableViewController.h"
#import "everyTableViewController.h"
#import "AppDelegate.h"
#import "TimelineCell.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import "everyBaseNavigationController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_SC_RECORDER = @"goSCRecorder";

@import AVFoundation;
@import QuartzCore;

@protocol MovieViewDelegate;

@interface RestaurantTableViewController ()
<TimelineCellDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
   // RestaurantPost *restaurantPost;
}

- (void)showDefaultContentView;

@property (nonatomic, copy) NSMutableArray *postid_;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end


@implementation RestaurantTableViewController
{
    NSString *_text, *_hashTag;
}
@synthesize postRestName = _postRestName;
@synthesize headerLocality = _headerLocality;
@synthesize postLon = _postLon;
@synthesize postLat = _postLat;
@synthesize lon;
@synthesize lat;

-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag
{
    self = [super init];
    if (self) {
        _text = text;
        _hashTag = hashTag;
    }
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //ナビゲーションバーに画像
    {
        //タイトル画像設定
        CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
        CGFloat width_image = height_image;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_image, height_image)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
    }
    
    //    self.navigationItem.title = @"レストラン";	// !!!:dezamisystem
    //背景にイメージを追加したい
    //UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    
    // !!!:dezamisystem
    //	self.navigationItem.backBarButtonItem = backButton;
    
    // Table View の設定
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineCell" bundle:nil]
         forCellReuseIdentifier:TimelineCellIdentifier];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	// !!!:dezamisystem
	[self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
	
    self.restname.text = _postRestName;
    self.locality.text = _headerLocality;
    NSLog(@"This Restaurant is %@",_postRestName);
   // lon = restaurantPost.lon;
   // lat = restaurantPost.lat;
    NSLog(@"This Restaurant is lat=%@ lon=%@",lat,lon);
    // グローバル変数に保存
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.gText = _postRestName;

    [SVProgressHUD dismiss];
   
    // API からタイムラインのデータを取得
    [self _fetchRestaurant];
}

//// !!!:dezamisystem
//- (void)navigationController:(UINavigationController *)navigationController
//	   didShowViewController:(UIViewController *)viewController
//					animated:(BOOL)animated
//{
//
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
        [self showDefaultContentView];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    // 動画データを一度全て削除
    [[MoviePlayerManager sharedManager] removeAllPlayers];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Action
/*
- (IBAction)pushMap:(UIButton *)sender {
    NSString *mapText = _postRestName;
    mapText = [mapText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *directions = [NSString stringWithFormat:
                            @"comgooglemaps://?q=%@&center=%@,%@&zoom=18",mapText,_postLon,_postLat];
    NSLog(@"URLSchemes:%@",directions);
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:directions]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
        //アラート出す
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ナビゲーション使用にはGoogleMapのアプリが必要です"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
    }

}
 */



- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate5"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate5"];
    // 保存
    [userDefaults synchronize];
    // 初回起動
    return YES;
}

- (void)showDefaultContentView
{
    if (!_firstContentView) {
        _firstContentView = [DemoContentView defaultView];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(20, 8, 260, 100);
        descriptionLabel.numberOfLines = 0.;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:18.];
        descriptionLabel.text = @"レストラン画面ではレストランの疑似体験ができます";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}

- (IBAction)unwindToTop:(UIStoryboardSegue *)segue
{
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
    
    cell.delegate = self;
    
    // セルにデータを反映
    TimelinePost *post = self.posts[indexPath.row];
    [cell configureWithTimelinePost:post];
    
    // 動画の読み込み
    LOG(@"読み込み完了");
    __weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL success) {
                                                       [weakSelf _playMovieAtCurrentCell];
                                                   }];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_METHOD;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.85];
}


//Twitterのアクティビティ投稿の基準
-(id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    // Twitterの時だけハッシュタグをつける
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return [NSString stringWithFormat:@"%@ #%@", _text, _hashTag];
    }
    return _text;
}


-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return _text;
}


//ナビゲーションのアクションボタンを押した時の動作
- (IBAction)share:(id)sender
{
    RestaurantTableViewController *text = [[RestaurantTableViewController alloc] initWithText:@"本文はこちらです。" hashTag:@"Gocci"];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // スクロール中は動画を停止する
  // [[MoviePlayerManager sharedManager] scrolling:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // [moviePlayer play];
     [self _playMovieAtCurrentCell];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self _playMovieAtCurrentCell];
        NSLog(@"scroll is stoped");
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {

    NSLog(@"scroll is stoped");
}







// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

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
	
	//プロフィール画面にパラメータを渡して遷移する
	// !!!:dezamisystem
//	if ([segue.identifier isEqualToString:@"goOthersTimeline2"])
	if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
	{
		//ここでパラメータを渡す
		NSLog(@"ここは通った");
		usersTableViewController_other *useVC = segue.destinationViewController;
		useVC.postUsername = _postUsername;
		useVC.postPicture = _postPicture;
	}
}

#pragma mark - Cell Event
//#pragma mark いいねボタンの時の処理
//- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapGoodWithPostID:(NSString *)postID
//{
//   //いいねボタンの時の処理
//    LOG(@"postid=%@", postID);
//    NSString *content = [NSString stringWithFormat:@"post_id=%@", postID];
//    NSLog(@"content:%@",content);
//    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/goodinsert/"];
//    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
//    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
//    NSURLResponse* response;
//    NSError* error = nil;
//    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
//                                           returningResponse:&response
//                                                       error:&error];
//	if (result) {
//		//
//	}
//    
//    // タイムラインを再読み込み
//    [self _fetchRestaurant];
//}
//
//#pragma mark バッドボタンの時の処理
//- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapBadWithPostID:(NSString *)postID
//{
//    //バッドボタンの時の処理
//    LOG(@"postid=%@", postID);
//    NSString *content = [NSString stringWithFormat:@"post_id=%@", postID];
//    NSLog(@"content:%@",content);
//    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/badinsert/"];
//    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
//    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
//    NSURLResponse* response;
//    NSError* error = nil;
//    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
//                                           returningResponse:&response
//                                                       error:&error];
//    NSLog(@"result:%@",result);
//    
//    
//    // タイムラインを再読み込み
//    [self _fetchRestaurant];
//}
//
//#pragma mark コメントボタン押下時の処理
//- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapCommentWithPostID:(NSString *)postID
//{
//    // コメントボタン押下時の処理
//    LOG(@"postid=%@", postID);
//    _postID = postID;
//	// !!!:dezamisystem
////    [self performSegueWithIdentifier:@"showDetail2" sender:postID];
//	[self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
//}

#pragma mark user_nameタップの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserName:(NSString *)userName
{
    //user nameタップの時の処理
	LOG(@"username=%@", userName);
	_postUsername = userName;
	LOG(@"postUsername:%@",_postUsername);
	// !!!:dezamisystem
//    [self performSegueWithIdentifier:@"goOthersTimeline2" sender:self];
	[self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
	LOG(@"Username is touched");
}

#pragma mark user_nameタップの時の処理②
- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserPicture:(NSString *)userPicture
{
    //user nameタップの時の処理②
    LOG(@"userspicture=%@", userPicture);
    _postPicture = userPicture;
    LOG(@"postUsername:%@",_postPicture);
    //[self performSegueWithIdentifier:@"goOthersTimeline" sender:self];
    LOG(@"Username is touched");
}


#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchRestaurant
{
    __weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSString *restName = _postRestName;
    LOG(@"restName:%@",restName);
    
    [APIClient restaurantWithRestName:(NSString *)restName handler:^(id result, NSUInteger code, NSError *error) {
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
    }];
}

/**
 *  現在表示中のセルの動画を再生する
 */
- (void)_playMovieAtCurrentCell
{
	// !!!:dezamisystem
    if (self.navigationController.topViewController != self) {
        // 画面がフォアグラウンドのときのみ再生
        return;
    }
    
    TimelineCell *currentCell = [self _currentCell];
    [[MoviePlayerManager sharedManager] scrolling:NO];
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:CGRectMake((self.tableView.frame.size.width - currentCell.thumbnailView.frame.size.width) / 2,
                                                                    currentCell.frame.size.height * [self _currentIndexPath].row + currentCell.thumbnailView.frame.origin.y+160,
                                                                    currentCell.thumbnailView.frame.size.width,
                                                                    currentCell.thumbnailView.frame.size.height)];
}

/**
 *  現在表示中のセルを取得
 *
 *  @return
 */
- (TimelineCell *)_currentCell
{
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

#pragma mark - 投稿するボタン
- (IBAction)onPostingButton:(id)sender {
	
	[self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER sender:self];
}

@end
