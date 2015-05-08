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
#import "RestaurantCell.h"
#import "APIClient.h"

#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import "everyBaseNavigationController.h"
#import "Reachability.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_SC_RECORDER = @"goSCRecorder";

@import AVFoundation;
@import QuartzCore;

@protocol MovieViewDelegate;

@interface RestaurantTableViewController ()
<RestaurantCellDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
   // RestaurantPost *restaurantPost;
}

- (void)showDefaultContentView;

@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *telButtonLabel;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end


@implementation RestaurantTableViewController
{
    NSString *_text, *_hashTag;
}
@synthesize postRestName = _postRestName;
@synthesize postLocality = _postLocality;
@synthesize postTell = _postTell;
@synthesize postHomepage = _postHomepage;
@synthesize postCategory = _postCategory;
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
        //CGFloat width_image = height_image;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
        
    }
    
    NSLog(@"postCategory:%@",_postCategory);
    
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    
    //[self.telButton setTitle:_postTell forState:UIControlStateNormal];
    self.telButtonLabel.text = _postTell;
    if (_postHomepage == nil) {
       
    }
    
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"RestaurantCell" bundle:nil]
         forCellReuseIdentifier:RestaurantCellIdentifier];
    
    // Pull to refresh
    self.refresh = [UIRefreshControl new];
    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	// !!!:dezamisystem
	[self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
	
    self.restname.text = _postRestName;
    self.locality.text = _postLocality;
    self.categoryLabel.text = _postCategory;
    NSLog(@"postCategory2:%@",_postCategory);
    
    NSLog(@"This Restaurant is %@",_postRestName);
    NSLog(@"This Locality is %@",_postLocality);
    NSLog(@"This Tell is %@",_postTell);
    NSLog(@"This Homepage is %@",_postHomepage);
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
        descriptionLabel.text = @"レストランの疑似体験ができます";
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
    return [RestaurantCell cellHeightWithTimelinePost:self.posts[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = RestaurantCellIdentifier;
    RestaurantCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [RestaurantCell cell];
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

     [SVProgressHUD dismiss];
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
   //  [self _playMovieAtCurrentCell];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
     //   [self _playMovieAtCurrentCell];
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
- (void)timelineCell:(RestaurantCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
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
    
    // タイムラインを再読み込み
    [self _fetchRestaurant];
}


- (void)restaurantCell:(RestaurantCell *)cell didTapViolateButtonWithPostID:(NSString *)postID
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


- (IBAction)tapTEL {
    
    NSString *number = @"tel:";
    NSString *telstring = [NSString stringWithFormat:@"%@%@",number,_postTell];
    NSLog(@"telstring:%@",telstring);
    NSURL *url = [[NSURL alloc] initWithString:telstring];
    [[UIApplication sharedApplication] openURL:url];
    
}
- (IBAction)tapNavi:(id)sender {
    NSString *mapText = _postRestName;
    NSString *mapText2 = _postLocality;
    mapText = [mapText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    mapText2  = [mapText2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *directions = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@&zoom=18",mapText2];
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

    NSString *urlString = _postHomepage;
    NSLog(@"tapHomepage:%@",_postHomepage);
    NSURL *url = [NSURL URLWithString:urlString];
    // ブラウザを起動する
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark コメントボタン押下時の処理
- (void)restaurantCell:(RestaurantCell *)cell didTapCommentButtonWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;

	[self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
}


#pragma mark user_nameタップの時の処理
- (void)restaurantCell:(RestaurantCell *)cell didTapNameWithUserName:(NSString *)userName picture:(NSString *)usersPicture
{
    //user nameタップの時の処理
	LOG(@"username=%@", userName);
	_postUsername = userName;
    _postPicture = usersPicture;
	LOG(@"postUsername:%@",_postUsername);
	// !!!:dezamisystem
//    [self performSegueWithIdentifier:@"goOthersTimeline2" sender:self];
	[self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
	LOG(@"Username is touched");
}

-(void)restaurantCell:(RestaurantCell *)cell didTapNaviWithLocality:(NSString *)Locality
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
- (void)restaurantCell:(RestaurantCell *)cell didTapNameWithUserPicture:(NSString *)userPicture
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
    [SVProgressHUD show];
    
    LOG(@"restName:%@",_postRestName);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.refresh beginRefreshing];
    
    __weak typeof(self)weakSelf = self;
    [APIClient restaurantWithRestName:_postRestName handler:^(id result, NSUInteger code, NSError *error) {
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
                /*3G回線接続のときの処理*/
                break;
            case ReachableViaWiFi:
                //WiFi
                
                break;
                
            default:
                
                break;
        }

        
        if ([self.posts count]== 0) {
            NSLog(@"投稿がない");
            _emptyView.hidden = NO;
            [SVProgressHUD dismiss];

        }
        
        if ([weakSelf.refresh isRefreshing]) {
            [weakSelf.refresh endRefreshing];
        }
    }];
}

- (void)restaurantCell:(RestaurantCell *)cell didTapthumb:(UIImageView *)thumbnailView{
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
        
        currentHeight += [RestaurantCell cellHeightWithTimelinePost:self.posts[i]];
    }
    
    RestaurantCell *currentCell = [RestaurantCell cell];
    [currentCell configureWithTimelinePost:self.posts[[self _currentIndexPath].row]];
    CGRect movieRect = CGRectMake((self.tableView.frame.size.width - currentCell.thumbnailView.frame.size.width) / 2,
                                  currentHeight + currentCell.thumbnailView.frame.origin.y+280,
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



#pragma mark - 投稿するボタン
- (IBAction)onPostingButton:(id)sender {
	
	self.tabBarController.selectedIndex = 0;
	
	//[self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER sender:self];
}

@end
