//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController_other.h"
#import "everyTableViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "everyBaseNavigationController.h"
#import "SVProgressHUD.h"
#import "TimelineCell.h"
#import "BBBadgeBarButtonItem.h"
#import "NotificationViewController.h"
#import "everyTableViewController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@import QuartzCore;

@protocol MovieViewDelegate;

@interface usersTableViewController_other ()
<TimelineCellDelegate>{
    NSDictionary *header;
}

@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSString *status_;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (weak, nonatomic) IBOutlet UIButton *UIalot;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation usersTableViewController_other

@synthesize postUsername= _postUsername;
@synthesize postPicture= _postPicture;

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
    
    
    
    // !!!:dezamisystem
    //	self.navigationItem.title = _postUsername;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    // Table View の設定
    self.tableView.allowsSelection = NO;
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

-(IBAction)light:(id)sender {
    
    if(flash_on == 0 ){
        
        // API からデータを取得
        [APIClient postFollow:[header objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
            if ([result[@"code"] integerValue] == 200) {
                UIImage *img = [UIImage imageNamed:@"フォロー解除.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 1;
                NSLog(@"フォローしました");
            }
        }
         ];
        
        
        
    }else if (flash_on == 1){
        
        [APIClient postUnFollow:[header objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
            if ((code=200)) {
                NSLog(@"フォロー解除しました");
                UIImage *img = [UIImage imageNamed:@"フォロー.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 0;
            }
        }
         ];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    // !!!:dezamisystem
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー非表示
    
    [self _fetchProfile_other];
    [self.tableView reloadData];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    // 動画データを一度全て削除
    //[[MoviePlayerManager sharedManager] removeAllPlayers];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Action

- (void)refresh:(UIRefreshControl *)sender
{
    [self _fetchProfile_other];
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
    if (!cell){
        cell = [TimelineCell cell];
    }
    
    // セルにデータを反映
    TimelinePost *post = self.posts[indexPath.row];
    [cell configureWithTimelinePost:post];
    cell.delegate = self;
    
    // 動画の読み込み
    LOG(@"読み込み完了");
    __weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL f){}];
    
    return cell ;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //セグエで画面遷移させる
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // スクロール中は動画を停止する
    // [[MoviePlayerManager sharedManager] scrolling:YES];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    LOG(@"scroll is stoped");
    // [self _playMovieAtCurrentCell];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        LOG(@"scroll is stoped");
        [self _playMovieAtCurrentCell];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // setContentOffset: 等によるスクロール終了
    NSLog(@"scroll is stoped");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //2つ目の画面にパラメータを渡して遷移する
    // !!!:dezamisystem
    //    if ([segue.identifier isEqualToString:@"showDetail3"])
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
        restVC.postRestName = [header objectForKey:@"user_id"];
    }
}


#pragma mark - TimelineCellDelegate

#pragma mark いいねボタンの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
{
    // API からデータを取得
    [APIClient postGood:postID handler:^(id result, NSUInteger code, NSError *error) {
        LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
    }
     ];
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



#pragma mark rest_nameタップの時の処理
-(void)timelineCell:(TimelineCell *)cell didTapRestaurant:(NSString *)rest_id
{
    NSLog(@"restname is touched");
    //rest nameタップの時の処理
    _postRestname = rest_id;
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


-(void)byoga{
    
    AppDelegate* profiledelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (profiledelegate) {}
    NSString *picturestring = [header objectForKey:@"profile_img"];
    self.profilename.text = [header objectForKey:@"username"];
    [self.profilepicture setImageWithURL:[NSURL URLWithString:picturestring]
                        placeholderImage:[UIImage imageNamed:@"default.png"]
     ];
    
    // Pull to refresh
    self.refresh = [UIRefreshControl new];
    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
     _status_ = [header objectForKey:@"follow_flag"];
    NSLog(@"statushere:%@",_status_);
    NSInteger i =  _status_.integerValue;
    int pi = (int)i;
    flash_on = pi;
    
    if(flash_on == 1){
        UIImage *img = [UIImage imageNamed:@"フォロー解除.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        UIImage *img = [UIImage imageNamed:@"フォロー.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    NSString *test = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSLog(@"%@=%@",test,[header objectForKey:@"username"]);
    if ([[header objectForKey:@"username"] isEqualToString:test]) {
        _flashBtn.hidden = YES;
    }
    
    [SVProgressHUD dismiss];
}

#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchProfile_other
{
    [SVProgressHUD show];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.refresh beginRefreshing];
    NSLog(@"updateUsername:%@",_postUsername);
    __weak typeof(self)weakSelf = self;
    [APIClient User:_postUsername handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        
        // 取得したデータを self.posts に格納
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        NSArray* items = (NSArray*)[result valueForKey:@"posts"];
        NSDictionary* headerDic = (NSDictionary*)[result valueForKey:@"header"];
        
        
        for (NSDictionary *post in items) {
            [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post]];
        }
        
        header = headerDic;
        self.posts = [NSArray arrayWithArray:tempPosts];
        
        
        // 動画データを一度全て削除
        [[MoviePlayerManager sharedManager] removeAllPlayers];
        
        // 表示の更新
        [weakSelf.tableView reloadData];
        
        
        if ([weakSelf.refresh isRefreshing]) {
            [weakSelf.refresh endRefreshing];
            [SVProgressHUD dismiss];
            
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
                                  currentHeight + currentCell.thumbnailView.frame.origin.y+230,
                                  currentCell.thumbnailView.frame.size.width,
                                  currentCell.thumbnailView.frame.size.height);
    
    [[MoviePlayerManager sharedManager] scrolling:NO];
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

@end
