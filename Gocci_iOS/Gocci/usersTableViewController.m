//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController.h"
#import "Sample5TableViewCell.h"
#import "SVProgressHUD.h"
#import "everyTableViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking/AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "ProfilePost.h"
#import "MoviePlayerManager.h"
#import "QuartzCore/QuartzCore.h"

@protocol MovieViewDelegate;

@interface usersTableViewController ()<Sample5TableViewCellDelegate>


@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) Sample5TableViewCell *cell;
@property (nonatomic, retain) NSIndexPath *nowindexPath;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation usersTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"プロフィール";
    //カスタムセルの導入
    UINib *nib = [UINib nibWithNibName:@"Sample5TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"usersTableViewCell"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    self.tableView.bounces = NO;
    [self.tableView setSeparatorColor:[UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:0.961]];
 
    AppDelegate* profiledelegate = [[UIApplication sharedApplication] delegate];
    self.profilename.text = profiledelegate.username;
    [self.profilepicture setImageWithURL:[NSURL URLWithString:profiledelegate.userpicture]
                       placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    // API からタイムラインのデータを取得
    [self _fetchProfile];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示

    [self _fetchProfile];
    [self.tableView reloadData];
    
    [SVProgressHUD dismiss];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
        // Return the number of rows in the section.
    return [self.posts count];
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

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



//1セルあたりの高さ
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  480.0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"usersTableViewCell";
    Sample5TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[Sample5TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:cellIdentifier];
    }
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:0.961];
    
    
    // セルにデータを反映
    ProfilePost *post = self.posts[indexPath.row];
    [cell configureWithProfilePost:post];
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
    
    return cell ;
}

- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapGoodWithPostID:(NSString *)postID
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
    [self _fetchProfile];
}


- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapBadWithPostID:(NSString *)postID
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
    [self _fetchProfile];
}


- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapRestnameWithrestname:(NSString *)restname
{
    //rest nameタップの時の処理
    LOG(@"restname=%@", restname);
    _postRestname = restname;
    NSLog(@"postRestname:%@",_postRestname);
    NSLog(@"Restname is touched");
    [self performSegueWithIdentifier:@"goRestpage" sender:self];
}

- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapCommentWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    [self performSegueWithIdentifier:@"showDetail2" sender:postID];

}

- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapDeleteWithPostID:(NSString *)postID
{
    // 削除ボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    Class class = NSClassFromString(@"UIAlertController");
    if(class){
        
        // iOS 8の時の処理
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を削除してもいいですか？" preferredStyle:UIAlertControllerStyleAlert];
        
        // addActionした順に左から右にボタンが配置されます
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         
            
            NSString *content = [NSString stringWithFormat:@"post_id=%@",postID];
            NSLog(@"content:%@",content);
            NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/delete/"];
            NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLResponse* response;
            NSError* error = nil;
            NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                   returningResponse:&response
                                                               error:&error];
           [self _fetchProfile];
           [self.tableView reloadData];
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
    
        NSString *content = [NSString stringWithFormat:@"post_id=%@",postID];
        NSLog(@"content:%@",content);
        NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/delete/"];
        NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLResponse* response;
        NSError* error = nil;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                               returningResponse:&response
                                                           error:&error];
        
        [self _fetchProfile];
        [self.tableView reloadData];
    
    }}



#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchProfile
{
    __weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AppDelegate* profiledelegate = [[UIApplication sharedApplication] delegate];
    NSString *userName = profiledelegate.username;
     [APIClient profileWithUserName:(NSString *)userName handler:^(id result, NSUInteger code, NSError *error) {
         
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        
        // 取得したデータを self.posts に格納
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *post in result) {
            [tempPosts addObject:[ ProfilePost profilePostWithDictionary:post]];
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
    
    Sample5TableViewCell *currentCell = [self _currentCell];
    [[MoviePlayerManager sharedManager] scrolling:NO];
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:CGRectMake(0,
                                                                    currentCell.frame.size.height * [self _currentIndexPath].row + currentCell.thumbnailView.frame.origin.y+66,
                                                                    currentCell.thumbnailView.frame.size.width,
                                                                    currentCell.thumbnailView.frame.size.height)];
}

/**
 *  現在表示中のセルを取得
 *
 *  @return
 */
- (Sample5TableViewCell *)_currentCell
{
    return (Sample5TableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:[self _currentIndexPath]];
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail2"]) {
        //ここでパラメータを渡す
        everyTableViewController *eveVC = segue.destinationViewController;
        eveVC.postID = _postID;
    }
    //店舗画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"goRestpage"]) {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    
}

@end
