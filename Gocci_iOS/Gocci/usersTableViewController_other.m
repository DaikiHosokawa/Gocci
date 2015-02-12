//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController_other.h"
#import "everyTableViewController.h"
#import "TimelineCell.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "everyBaseNavigationController.h"
#import "SVProgressHUD.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@import QuartzCore;

@protocol MovieViewDelegate;

@interface usersTableViewController_other ()
<TimelineCellDelegate>

@property (nonatomic, copy) NSMutableArray *postid_;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation usersTableViewController_other

@synthesize postUsername= _postUsername;
@synthesize postPicture= _postPicture;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//ナビゲーションバーに画像
	{
		//タイトル画像設定
		CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
		CGFloat width_image = height_image;
		UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
		UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
		self.navigationItem.titleView =navigationTitle;
	}

	// !!!:dezamisystem
//	self.navigationItem.title = _postUsername;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
	// !!!:dezamisystem
//	self.navigationItem.backBarButtonItem = backButton;
    
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
   
    // API からタイムラインのデータを取得
    [self _fetchProfile_other];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
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

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
                                                   completion:^(BOOL success) {
                                                       [weakSelf _playMovieAtCurrentCell];
                                                   }];
    
    
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
    [self _playMovieAtCurrentCell];
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
    }
}


#pragma mark - TimelineCellDelegate

#pragma mark いいねボタンの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
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
//
//#pragma mark バッドボタンの時の処理
//- (void)sample5TableViewCell_other:(Sample5TableViewCell_other *)cell didTapBadWithPostID:(NSString *)postID
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
//    [self _fetchProfile_other];
//}

#pragma mark rest_nameタップの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapRestaurant:(NSString *)restaurantName
{
    //rest nameタップの時の処理
    LOG(@"restname=%@", restaurantName);
    _postRestname = restaurantName;
    LOG(@"postRestname:%@",_postRestname);
    LOG(@"Restname is touched");

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
- (void)_fetchProfile_other
{
    __weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *userName = _postUsername;
    [APIClient profileWithUserName:(NSString *)userName handler:^(id result, NSUInteger code, NSError *error) {
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
                                                                    currentCell.frame.size.height * [self _currentIndexPath].row + currentCell.thumbnailView.frame.origin.y+66,
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


@end
