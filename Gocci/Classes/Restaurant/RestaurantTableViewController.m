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
#import "APIClient.h"
#import "TimelineCell.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import "everyBaseNavigationController.h"
#import "CustomAnnotation.h"
#import "NotificationViewController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_SC_RECORDER = @"goSCRecorder";

@import AVFoundation;
@import QuartzCore;

@protocol MovieViewDelegate;

@interface RestaurantTableViewController ()
<TimelineCellDelegate,MKMapViewDelegate>
{
    __weak IBOutlet MKMapView *map_;
    // RestaurantPost *restaurantPost;
    NSDictionary *header;
}


@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end


@implementation RestaurantTableViewController
{
    NSString *_text, *_hashTag;
}
@synthesize postRestName = _postRestName;;

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
    self.navigationItem.rightBarButtonItem = self.barButton;
    
    
    //ナビゲーションバーに画像
    {
        //タイトル画像設定
        //CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
        //CGFloat width_image = height_image;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
        
        
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
        
    }
    
    
    //_total_cheer_num.text = _postTotalCheer;
    //NSLog(@"postTotalCheer:%@",_postTotalCheer);
    
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineCell" bundle:nil]
         forCellReuseIdentifier:TimelineCellIdentifier];
    
    // Pull to refresh
    self.refresh = [UIRefreshControl new];
    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
    /*
     if (_status_) {
     NSString *dotse = _status_[1];
     NSLog(@"dotse:%@",dotse);
     NSInteger i = dotse.integerValue;
     int pi = (int)i;
     NSLog(@"pi:%d",pi);
     //NSLog(@"postFlag:%ld",(long)_postFlag);
     flash_on = pi;
     NSLog(@"flash_on:%d",flash_on);
     }else{
     NSInteger i = _postFlag;
     int pi = (int)i;
     NSLog(@"pi:%d",pi);
     //NSLog(@"postFlag:%ld",(long)_postFlag);
     flash_on = pi;
     NSLog(@"flash_on:%d",flash_on);
     }
     */
    
    
    //  NSLog(@"total_cheer_num:%@",_postTotalCheer);
    
    //set notificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"HogeNotification"
                             object:nil];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
 
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
    [map_ setRegion:region animated:NO];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // !!!:dezamisystem
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
  // API からタイムラインのデータを取得
    [self _fetchRestaurant];
    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
    }
    NSLog(@"header2^:%@",header);
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    // 動画データを一度全て削除
    //[[MoviePlayerManager sharedManager] removeAllPlayers];
    
    [super viewWillDisappear:animated];
    
    
}


#pragma mark - Action


- (void)refresh:(UIRefreshControl *)sender
{
    [self _fetchRestaurant];
}





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
    //__weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL f){}];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    //[self _playMovieAtCurrentCell];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self _playMovieAtCurrentCell];
        //   NSLog(@"scroll is stoped");
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
        [self.popover dismissPopoverAnimated:YES];
#endif
        eveVC.postID = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    
    //プロフィール画面にパラメータを渡して遷移する
    // !!!:dezamisystem
    //	if ([segue.identifier isEqualToString:@"goOthersTimeline2"])
    if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
    {
        usersTableViewController_other *users_other = segue.destinationViewController;
         users_other.postUsername = _postUsername;
    }
}

#pragma mark - Cell Event
//#pragma mark いいねボタンの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
{    // API からデータを取得
    [APIClient postGood:postID handler:^(id result, NSUInteger code, NSError *error) {
        LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
    }
     ];
    
    // タイムラインを再読み込み
    //[self _fetchRestaurant];
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
            
            [APIClient postBlock:postID handler:^(id result, NSUInteger code, NSError *error) {
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
        [APIClient postBlock:postID handler:^(id result, NSUInteger code, NSError *error) {
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

-(IBAction)light:(id)sender {
    
    if(flash_on == 0 ){
        
        [APIClient postWant:[header objectForKey:@"restname"] handler:^(id result, NSUInteger code, NSError *error) {
       //     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            
            if (code != 200 || error != nil) {
                // API からのデータの取得に失敗
                
                // TODO: アラート等を掲出
                return;
            }else{
                 NSLog(@"行きたいしました");
                NSLog(@"result:%@",result);
                UIImage *img = [UIImage imageNamed:@"Oen.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 1;
                
            }
    
            }];
        
    }else if (flash_on == 1){
        [APIClient postUnWant:[header objectForKey:@"restname"] handler:^(id result, NSUInteger code, NSError *error) {
         //   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            LOG(@"resultUnWant=%@", result);
            
            if (code != 200 || error != nil) {
                // API からのデータの取得に失敗
                
                // TODO: アラート等を掲出
                return;
            }else{
                NSLog(@"行きたい解除しました");
                UIImage *img = [UIImage imageNamed:@"notOen.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 0;
               
            }
            
        }];
    }
}

- (IBAction)tapTEL {
    
    if ([[header objectForKey:@"tell"] isEqualToString:@"非公開"] || [[header objectForKey:@"tell"] isEqualToString:@"準備中"]|| [[header objectForKey:@"tell"] isEqualToString:@"予約不可"]|| [[header objectForKey:@"tell"] isEqualToString:@"非設置"]|| [[header objectForKey:@"tell"] isEqualToString:@"none"]) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"申し訳ありません。電話番号が登録されておりません"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        NSString *number = @"tel:";
        NSString *telstring = [NSString stringWithFormat:@"%@%@",number,[header objectForKey:@"tell"]];
        NSLog(@"telstring:%@",telstring);
        NSURL *url = [[NSURL alloc] initWithString:telstring];
        [[UIApplication sharedApplication] openURL:url];
        
    }
}


- (IBAction)tapNavi:(id)sender {
    NSString *mapText = [header objectForKey:@"restname"];
    NSString *mapText2 = [header objectForKey:@"locality"];
    mapText = [mapText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    mapText2  = [mapText2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *directions = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@&zoom=18&directionsmode=walking",mapText2];
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

- (IBAction)tapHomepatge {
    
    NSString *urlString = [header objectForKey:@"homepage"];
    NSLog(@"tapHomepage:%@",[header objectForKey:@"homepage"]);
    NSURL *url = [NSURL URLWithString:urlString];
    // ブラウザを起動する
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark コメントボタン押下時の処理
- (void)timelineCell:(TimelineCell *)cell didTapCommentButtonWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    
    [self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
}


#pragma mark user_nameタップの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapUserName:(NSString *)user_id
{
    //user nameタップの時の処理
    _postUsername = user_id;
    NSLog(@"useridtoUsers:%@",_postUsername);
    //    [self performSegueWithIdentifier:@"goOthersTimeline2" sender:self];
    [self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
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
    } else {
        NSLog(@"Can't use comgooglemaps://");
        //アラート出す
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ナビゲーション使用にはGoogleMapのアプリが必要です"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
    }
}


#pragma mark user_nameタップの時の処理②
- (void)timelineCell:(TimelineCell *)cell didTapPicture:(NSString *)user_id
{
    _postUsername = user_id;
    
}

-(void)byoga{
    NSLog(@"header^:%@",header);
    
    self.restname.text = [header objectForKey:@"restname"];
    self.categoryLabel.text = [header objectForKey:@"rest_category"];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.restname = [header objectForKey:@"restname"];
    
    NSString *postLat = [header objectForKey:@"lat"];
    double latdo = postLat.doubleValue;
    _coordinate.latitude = latdo;
    
    self.total_cheer_num.text = [NSString stringWithFormat:@"%@", [header objectForKey:@"cheer_num"]];
    
    NSString *postLon = [header objectForKey:@"lon"];
    double londo = postLon.doubleValue;
    _coordinate.longitude = londo;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latdo
                                                            longitude:londo
                                                                 zoom:18];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.title = [header objectForKey:@"restname"];
    marker.snippet = [header objectForKey:@"locality"];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map  = _map;
    _map.selectedMarker = marker;
    GMSMapView* mapView = [GMSMapView mapWithFrame:map_.bounds camera:camera];
    [_map setCamera:camera];
    NSString *postWanttag = [header objectForKey:@"want_flag"];
    NSInteger i = postWanttag.integerValue;
    int pi = (int)i;
    flash_on = pi;
    
    if(flash_on == 1){
        
        UIImage *img = [UIImage imageNamed:@"Oen.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
        
    }else{
        
        UIImage *img = [UIImage imageNamed:@"notOen.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [SVProgressHUD dismiss];
    
}

#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchRestaurant
{
    [SVProgressHUD show];
    
    LOG(@"restName:%@",[header objectForKey:@"restname"]);
    
  //  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.refresh beginRefreshing];
    
    __weak typeof(self)weakSelf = self;
    [APIClient Restaurant:_postRestName handler:^(id result, NSUInteger code, NSError *error) {
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        LOG(@"resultRest1=%@", result);
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            
            // TODO: アラート等を掲出
            return;
        }
        
        // 取得したデータを self.posts に格納
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        NSArray* items = (NSArray*)[result valueForKey:@"posts"];
        NSDictionary* restaurants = (NSDictionary*)[result valueForKey:@"restaurants"];
        
        for (NSDictionary *dict in items) {
            [tempPosts addObject:[TimelinePost timelinePostWithDictionary:dict]];
        }
        
        header = restaurants;
        self.posts = [NSArray arrayWithArray:tempPosts];
        
        // 動画データを一度全て削除
        [[MoviePlayerManager sharedManager] removeAllPlayers];
        
        
        // 表示の更新
        [weakSelf.tableView reloadData];
        
        
        
        if ([self.posts count]== 0) {
            NSLog(@"投稿がない");
            _emptyView.hidden = NO;
            [SVProgressHUD dismiss];
            
        }
        
        if ([weakSelf.refresh isRefreshing]) {
            [weakSelf.refresh endRefreshing];
        }
        
        [self byoga];
    }];
}



/**
 *  現在表示中のセルの動画を再生する
 */
- (void)_playMovieAtCurrentCell
{
    
    if ( [self.posts count] == 0){
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
                                  currentHeight + currentCell.thumbnailView.frame.origin.y+430,
                                  currentCell.thumbnailView.frame.size.width,
                                  currentCell.thumbnailView.frame.size.height);
    
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:movieRect];
    
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

- (IBAction)onOther:(UIButton *)sender {
    
    UIActionSheet *actionsheet = nil;
    actionsheet = [[UIActionSheet alloc] initWithTitle:@"その他"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"ホームページを見る",nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"cancel");
    }else if(buttonIndex == 0) {
        NSLog(@"%@",[header objectForKey:@"homepage"]);
        if ([[header objectForKey:@"homepage"] isEqualToString:@"none"]||[[header objectForKey:@"homepage"] isEqualToString:@"準備中"]) {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"申し訳ありません。ホームページが登録されておりません"
                                      delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[header objectForKey:@"homepage"]]];
        }
    }
}

#pragma mark - 投稿するボタン
- (IBAction)onPostingButton:(id)sender {
    
    self.tabBarController.selectedIndex = 2;
    
    //[self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER sender:self];
}

- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
    
}


-(void)barButtonItemPressed:(id)sender{
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
                                                    self.barButton.accessibilityFrame.origin.x + 15, self.barButton.accessibilityFrame.origin.y + 30, self.barButton.accessibilityFrame.size.width, self.barButton.accessibilityFrame.size.height)
                                  inView:self.barButton.customView
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
}

@end
