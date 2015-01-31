//
//  TimelineTableViewController.m
//  Gocci
//


#import "TimelineTableViewController.h"
#import "searchTableViewController.h"
#import "Sample2TableViewCell.h"
#import "everyTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking/AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "usersTableViewController.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "QuartzCore/QuartzCore.h"


@protocol MovieViewDelegate;

@interface TimelineTableViewController ()
<CLLocationManagerDelegate, Sample2TableViewCellDelegate>
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

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation TimelineTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    // API からタイムラインのデータを取得
    [self _fetchTimeline];

    [self.navigationItem setHidesBackButton:YES animated:NO];
    [SVProgressHUD dismiss];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
      [self showDefaultContentView];
    }
    self.navigationItem.leftBarButtonItem.enabled = YES;
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


#pragma mark -
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
        descriptionLabel.text = @"タイムライン画面では最新情報が見れます。";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}


- (IBAction)pushUserTimeline:(id)sender {

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;//pushのトランジション
    transition.subtype = kCATransitionFromRight;//右から左へ
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    usersTableViewController *userTimeline = [[usersTableViewController alloc]init];
    [self.navigationController pushViewController:userTimeline animated:YES];
}

- (IBAction)onProfileButton:(id)sender
{
    usersTableViewController *controller = [usersTableViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidLoad
{
     [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, 500, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"Gocci";
    self.navigationItem.titleView = label;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
   
    UINib *nib = [UINib nibWithNibName:@"Sample2TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TimelineTableViewCell"];
    
    self.tableView.bounces = NO;
     [self.tableView setSeparatorColor:[UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:0.961]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    // スクロール中は動画を停止する
   // [[MoviePlayerManager sharedManager] scrolling:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// フリック操作によるスクロール終了
    LOG(@"scroll is stoped");
    
    [self _playMovieAtCurrentCell];
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

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 550.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"TimelineTableViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[Sample2TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:cellIdentifier];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:0.961];
    
    // セルにデータを反映
    TimelinePost *post = self.posts[indexPath.row];
    [cell configureWithTimelinePost:post];
    cell.delegate = self;
    
    // 動画の読み込み
    NSLog(@"読み込み完了");
    __weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL success) {
                                                       [weakSelf _playMovieAtCurrentCell];
                                                   }];
    
    return cell;
}

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    
    [self performSegueWithIdentifier:@"showDetail2" sender:self];
    NSLog(@"commentBtn is touched");
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    //セグエで画面遷移させる
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail2"]) {
        //ここでパラメータを渡す
        everyTableViewController *eveVC = segue.destinationViewController;
        eveVC.postID = (NSString *)sender;
    }
    //プロフィール画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"goOthersTimeline"]) {
        //ここでパラメータを渡す
        usersTableViewController_other *useVC = segue.destinationViewController;
        useVC.postUsername = _postUsername;
        useVC.postPicture = _postPicture;
    }
    //店舗画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"goRestpage"]) {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    
    
}


#pragma mark - Sample2TableViewCellDelegate

- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapGoodWithPostID:(NSString *)postID
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
    [self _fetchTimeline];
}


- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapBadWithPostID:(NSString *)postID
{
    //バッドボタンの時の処理
    LOG(@"postid=%@", postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@", postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/badinsert/"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                                                       error:&error];
    NSLog(@"result:%@",result);
    
    
    // タイムラインを再読み込み
    [self _fetchTimeline];
}

- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapNameWithusername:(NSString *)username
{
    //user nameタップの時の処理
    LOG(@"username=%@", username);
    _postUsername = username;
    NSLog(@"postUsername:%@",_postUsername);
    [self performSegueWithIdentifier:@"goOthersTimeline" sender:self];
    NSLog(@"Username is touched");
    
}

- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapNameWithuserspicture:(NSString *)userspicture
{
    //user nameタップの時の処理②
    LOG(@"userspicture=%@", userspicture);
    _postPicture = userspicture;
    NSLog(@"postUsername:%@",_postPicture);
    //[self performSegueWithIdentifier:@"goOthersTimeline" sender:self];
    NSLog(@"Username is touched");
    
}

- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapRestnameWithrestname:(NSString *)restname
{
    //rest nameタップの時の処理
    LOG(@"restname=%@", restname);
    _postRestname = restname;
    NSLog(@"postRestname:%@",_postRestname);
    NSLog(@"Restname is touched");
     [self performSegueWithIdentifier:@"goRestpage" sender:self];
}


- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapCommentWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    [self performSegueWithIdentifier:@"showDetail2" sender:postID];
}


#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchTimeline
{
    __weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *limit = @"50";
   [APIClient timelineWithHandler:(NSString *)limit  handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //LOG(@"result=%@", result);
        //LOG(@"code=%@, error=%@", @(code), error);
        
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
    if (self.navigationController.topViewController != self) {
        // 画面がフォアグラウンドのときのみ再生
        return;
    }
    
    Sample2TableViewCell *currentCell = [self _currentCell];
    [[MoviePlayerManager sharedManager] scrolling:NO];
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:CGRectMake((self.tableView.frame.size.width - currentCell.thumbnailView.frame.size.width) / 2,
                                                                    currentCell.frame.size.height * [self _currentIndexPath].row + currentCell.thumbnailView.frame.origin.y,
                                                                    currentCell.thumbnailView.frame.size.width,
                                                                    currentCell.thumbnailView.frame.size.height)];
}

/**
 *  現在表示中のセルを取得
 *
 *  @return
 */
- (Sample2TableViewCell *)_currentCell
{
    return (Sample2TableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:[self _currentIndexPath]];
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
