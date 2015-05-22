//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController_other.h"
#import "everyTableViewController.h"
#import "ProfileCell2.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "everyBaseNavigationController.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import "TimelineCell.h"
#import "BBBadgeBarButtonItem.h"
#import "NotificationViewController.h"


// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@import QuartzCore;

@protocol MovieViewDelegate;

@interface usersTableViewController_other ()
<TimelineCellDelegate>

@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSMutableArray *status_;
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
@synthesize postUsername_with_profile= _postUsername_with_profile;
@synthesize postUserPicture_with_profile= _postUserPicture_with_profile;
@synthesize postUsername_with_profile2= _postUsername_with_profile2;
@synthesize postUserPicture_with_profile2= _postUserPicture_with_profile2;
@synthesize postFlag = _postFlag;
@synthesize postTotalCheer = _postTotalCheer;

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
    
    // Table View の設定
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineCell" bundle:nil]
         forCellReuseIdentifier:TimelineCellIdentifier];
    
    AppDelegate* profiledelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	if (profiledelegate) {}
    NSString *picturestring = _postPicture;
    self.profilename.text = _postUsername;
    [self.profilepicture setImageWithURL:[NSURL URLWithString:picturestring]
                        placeholderImage:[UIImage imageNamed:@"default.png"]
	 ];
    
    // Pull to refresh
    self.refresh = [UIRefreshControl new];
    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
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
    
    if(flash_on == 1){
    UIImage *img = [UIImage imageNamed:@"フォロー解除.png"];
    [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        UIImage *img = [UIImage imageNamed:@"フォロー.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    NSString *test = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSLog(@"%@=%@",test,_postUsername);
    if ([_postUsername isEqualToString:test]) {
        _flashBtn.hidden = YES;
    }
    
    
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
        
        //スイッチオン時の処理を記述できます
      NSLog(@"フォローしました");
        NSString *content = [NSString stringWithFormat:@"user_name=%@",_postUsername];
        NSLog(@"content:%@",content);
        NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/favorites/"];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse* response;
        NSError* error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                               returningResponse:&response
                                                           error:&error];
        
        if (result) {
            UIImage *img = [UIImage imageNamed:@"フォロー解除.png"];
            [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
            flash_on = 1;
            NSLog(@"result:%@",result);

        }
        
    }else if (flash_on == 1){
          NSLog(@"フォロー解除しました");
        UIImage *img = [UIImage imageNamed:@"フォロー.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 0;
        //スイッチオフに戻った場合の処理を記述
        NSString *content = [NSString stringWithFormat:@"user_name=%@",_postUsername];
        NSLog(@"content:%@",content);
        NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/unfavorites/"];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse* response;
        NSError* error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                               returningResponse:&response
                                                           error:&error];
        if (result) {
            
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
	
    //JSONをパース
    NSString *timelineString = [NSString stringWithFormat:@"http://api-gocci.jp/mypage/?user_name=%@",_postUsername];
    NSString* escaped = [timelineString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* Url = [NSURL URLWithString:escaped];
    NSString *response = [NSString stringWithContentsOfURL:Url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"response:%@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSLog(@"jsonData:%@",jsonData);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"jsonDic:%@",jsonDic);
    //status
    NSArray *user_name = [jsonDic valueForKey:@"status"];
    _status_ = [user_name mutableCopy];
    NSLog(@"statusZ:%@",_status_);
    
    
	// !!!:dezamisystem
	[self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー非表示
	
	[self _fetchProfile_other];
    [self.tableView reloadData];

    [SVProgressHUD dismiss];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    // 動画データを一度全て削除
    [[MoviePlayerManager sharedManager] removeAllPlayers];


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

     [SVProgressHUD dismiss];
    
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
       // [self _playMovieAtCurrentCell];
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
        restVC.postHomepage = _postHomepage;
        restVC.postTell = _postTell;
        restVC.postLocality = _postLocality;
        restVC.postCategory = _postCategory;
        restVC.postLon = _postLon;
        restVC.postLat = _postLat;
        restVC.postTotalCheer = _postTotalCheer;
        restVC.postWanttag = _postWanttag;
    }
}


#pragma mark - TimelineCellDelegate

#pragma mark いいねボタンの時の処理
- (void)timelineCeloo:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
{
    //いいねボタンの時の処理
    LOG(@"postid=%@", postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@", postID];
    LOG(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/goodinsert/"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                                                       error:&error];
	if (result) {}
    
    // タイムラインを再読み込み
    [self _fetchProfile_other];
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
                NSString *alertMessage = @"違反報告をしました";
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

#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchProfile_other
{
    [SVProgressHUD show];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.refresh beginRefreshing];
    
    __weak typeof(self)weakSelf = self;
    [APIClient profileWithUserName: _postUsername handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
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
       NSLog(@"result_id:%@",result);
        NSLog(@"tempPosts:%@",tempPosts);
        NSLog(@"post:%@",_posts);
        
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

        
        if ([weakSelf.refresh isRefreshing]) {
            [weakSelf.refresh endRefreshing];
            [SVProgressHUD dismiss];
            
        }
    }];
}

- (void)timelineCell:(TimelineCell *)cell didTapthumb:(UIImageView *)thumbnailView{
    [self _playMovieAtCurrentCell];
}

/**
 *  現在表示中のセルの動画を再生する
 */
- (void)_playMovieAtCurrentCell
{
    
    Reachability *curReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    
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
