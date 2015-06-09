//
//  TimelineTableViewController.m
//  Gocci
//


#import "TimelineTableViewController.h"
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
#import "Reachability.h"
#import "BBBadgeBarButtonItem.h"
#import "NotificationViewController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@import AVFoundation;
@import QuartzCore;

@protocol MovieViewDelegate;

@interface TimelineTableViewController ()
<CLLocationManagerDelegate, TimelineCellDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
}

- (void)showDefaultContentView;

@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property (nonatomic, copy) NSMutableArray *postid_;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *notificationText;
@property (nonatomic, strong) UIRefreshControl *refresh;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation TimelineTableViewController
@synthesize thumbnailView;

#pragma mark - アイテム名登録用
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
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
	//    self.navigationItem.leftBarButtonItem.enabled = NO;

	// !!!:dezamisystem
//    [self.navigationItem setHidesBackButton:YES animated:NO];

    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    // 動画データを一度全て削除
    [[MoviePlayerManager sharedManager] removeAllPlayers];
    
}

#pragma mark - viewDidAppear
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
      [self showDefaultContentView];
    }
	// !!!:dezamisystem
//    self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate1"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate1"];
    // 保存
    [userDefaults synchronize];
    // 初回起動
    return YES;
}

-(void)barButtonItemPressed:(id)sender{
    NSLog(@"badge touched");
    
    self.barButton.badgeValue = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud removeObjectForKey:@"numberOfNewMessages"];
    
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


#pragma mark -
- (void)showDefaultContentView
{
    if (!_firstContentView) {
        _firstContentView = [DemoContentView defaultView];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(20, 8, 260, 100);
        descriptionLabel.numberOfLines = 0.;
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.];
        descriptionLabel.text = @"近くのグルメ情報が見れます";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}


#pragma mark - Action

- (IBAction)pushUserTimeline:(id)sender {

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;//pushのトランジション
    transition.subtype = kCATransitionFromRight;//右から左へ
	// !!!:dezamisystem
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//    usersTableViewController *userTimeline = [[usersTableViewController alloc]init];
//    [self.navigationController pushViewController:userTimeline animated:YES];
}

- (IBAction)onProfileButton:(id)sender
{
	// !!!:dezamisystem

//    usersTableViewController *controller = [usersTableViewController new];
//    [self.navigationController pushViewController:controller animated:YES];
}

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
    //一番下までスクロールしたかどうか
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
        //まだ表示するコンテンツが存在するか判定し存在するなら○件分を取得して表示更新する
    }
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// フリック操作によるスクロール終了
    LOG(@"scroll is stoped");
    
  // [self _playMovieAtCurrentCell];
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
    NSLog(@"scroll is stoped");
}



// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
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
    __weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL f){}];
     [SVProgressHUD dismiss];
    
    
    return cell;
}

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    
    //[self performSegueWithIdentifier:@"showDetail2" sender:self];
	// !!!:dezamisystem
	[self performSegueWithIdentifier:@"showDetail" sender:self];
	
	
    NSLog(@"commentBtn is touched");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択状態の解除
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 遷移前準備
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //2つ目の画面にパラメータを渡して遷移する
//    if ([segue.identifier isEqualToString:@"showDetail2"])
	// !!!:dezamisystem
	if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
	{
        //ここでパラメータを渡す
#if 0
		everyTableViewController *eveVC = segue.destinationViewController;
#else
		everyBaseNavigationController *eveNC = segue.destinationViewController;
		everyTableViewController *eveVC = (everyTableViewController*)[eveNC rootViewController];
#endif
        eveVC.postID = (NSString *)sender;
    }
    //プロフィール画面にパラメータを渡して遷移する
//    if ([segue.identifier isEqualToString:@"goOthersTimeline"])
	// !!!:dezamisystem
	if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
	{
        //ここでパラメータを渡す
        usersTableViewController_other *useVC = segue.destinationViewController;
        useVC.postUsername = _postUsername;
        useVC.postPicture = _postPicture;
        useVC.postFlag = _postFlag;
    }
    //店舗画面にパラメータを渡して遷移する
//	if ([segue.identifier isEqualToString:@"goRestpage"])
	if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
	{
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
        restVC.postHomepage = _postHomepage;
        restVC.postLocality = _postLocality;
        restVC.postCategory = _postCategory;
        restVC.postLon = _postLon;
        restVC.postLat = _postLat;
        restVC.postTell = _postTell;
        restVC.postTotalCheer = _postTotalCheer;
        restVC.postWanttag = _postWanttag;
    }
}


#pragma mark - TimelineCellDelegate

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
    

    //[self.view performSelectorOnMainThread:@selector(updateDisplay) withObject:nil waitUntilDone:YES];
    //_currentIndexPath
  
	if (result) {}
   
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
            
            
            NSString *content = [NSString stringWithFormat:@"post_id=%@",postID];
            NSLog(@"content:%@",content);
            NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/violation/"];
            NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLResponse* response;
            NSError* error = nil;
            NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                   returningResponse:&response                                                               error:&error];
            if (result) {
                NSString *alertMessage = @"違反報告をしました。";
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show];
}
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        NSString *content = [NSString stringWithFormat:@"post_id=%@",postID];
        NSLog(@"content:%@",content);
        NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/violation/"];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse* response;
        NSError* error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                               returningResponse:&response
                                                           error:&error];
        if (result) {
            NSString *alertMessage = @"違反報告をしました";
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alrt show];
}
        
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

	//[self performSegueWithIdentifier:@"goOthersTimeline" sender:self];
	// !!!:dezamisystem
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

#pragma mark user_nameタップの時の処理 2
- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserPicture:(NSString *)userPicture name:(NSString *)userName flag:(NSInteger)flag
{
    //user nameタップの時の処理 2
    LOG(@"userspicture=%@", userPicture);
    _postPicture = userPicture;
    _postUsername = userName;
    _postFlag = flag;
    
    LOG(@"postUsername:%@",_postUsername);
    
    //[self performSegueWithIdentifier:@"goOthersTimeline" sender:self];
    // !!!:dezamisystem
    [self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
    
    LOG(@"Username is touched");
    LOG(@"postUsername:%@",_postPicture);
    //[self performSegueWithIdentifier:@"goOthersTimeline" sender:self];
    LOG(@"Username is touched");
}

- (void)timelineCell:(TimelineCell *)cell didTapRestaurant:(NSString *)restaurantName locality:(NSString *)locality tel:(NSString *)tel homepage:(NSString *)homepage category:(NSString *)category lon:(NSString *)lon lat:(NSString *)lat total_cheer:(NSString *)total_cheer want_tag:(NSString *)want_tag
{
    NSLog(@"restname is touched");
    //rest nameタップの時の処理
    _postRestname = restaurantName;
    _postHomepage = homepage;
    _postLocality = locality;
    _postCategory = category;
    _postLat = lat;
    _postLon = lon;
    _postTell = tel;
    _postTotalCheer = total_cheer;
    _postWanttag = want_tag;
    NSLog(@"restname=%@", restaurantName);
    NSLog(@"locality=%@", locality);
    NSLog(@"tel=%@", tel);
    NSLog(@"homepage=%@", homepage);
    NSLog(@"category=%@", category);
	[self performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:self];
}

- (void)timelineCell:(TimelineCell *)cell didTapCommentButtonWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;

	[self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
}


#pragma mark - Private Methods

/**
 *  タイムラインのデータを取得
 */
- (void)_fetchTimeline
{
    [self _fetchTimelineUsingLocationCache:YES];
}



/**
 *  近くのお店のタイムラインのデータを取得
 *
 *  @param usingLocationCache 前回取得した位置情報を利用する場合 YES を指定
 */
- (void)_fetchTimelineUsingLocationCache:(BOOL)usingLocationCache
{
    
    [SVProgressHUD show];
    
    __weak typeof(self)weakSelf = self;
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [weakSelf.refresh beginRefreshing];
        
        // API からデータを取得
        [APIClient distTimelineWithLatitude:coordinate.latitude
                                  longitude:coordinate.longitude
                                      limit:50
                                    handler:^(id result, NSUInteger code, NSError *error)
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
             NSLog(@"rposts:%@",_posts);
             if ([self.posts count]== 0) {
                 
                 
                 Class class = NSClassFromString(@"UIAlertController");
                 if(class)
                 {
                     // iOS 8の時の処理
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"近くに投稿がありません。全体の投稿を再度取得しますか？" preferredStyle:UIAlertControllerStyleAlert];
                     
                     // addActionした順に左から右にボタンが配置されます
                     [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                         
                         //はいのときのアクション内容
                         [self _fetchTimelineUsingLocationCacheALL:YES];
                         
                         if (result) {
                             
                         }
                     }]];
                     
                     [self presentViewController:alertController animated:YES completion:nil];
                 }
                 else
                 {
                     //その他の時のアクション内容
                     
                     if (result) {
                         //はいのときのアクション内容
                         [self _fetchTimelineUsingLocationCacheALL:YES];
                     }
                 }
             }
             
             // 動画データを一度全て削除
             [[MoviePlayerManager sharedManager] removeAllPlayers];
             
             // 表示の更新
             [weakSelf.tableView reloadData];
    
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
        [APIClient distTimelineWithLatitudeAll:coordinate.latitude
                                   longitude:coordinate.longitude
                                       limit:50
                                     handler:^(id result, NSUInteger code, NSError *error)
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
        
             BOOL isServerAvailable;
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
                     /*3G回線接続のときの処理*/
                     break;
                 case ReachableViaWiFi:
                     //WiFi
                     
                     break;
                     
                 default:
                     
                     break;
             }

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
    /*
    if ( [self.posts count] == 0){
        return;
    }
    */
    
    if (self.tabBarController.selectedIndex != 0) {
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

@end
