//
//  RestaurantTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "RestaurantTableViewController.h"
#import "searchTableViewController.h"
#import "Sample3TableViewCell.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "SVProgressHUD.h"
#import "everyTableViewController.h"
#import "UIImageView+WebCache.h"
#import "APIClient.h"
#import "RestaurantPost.h"
#import "MoviePlayerManager.h"
#import "QuartzCore/QuartzCore.h"

@protocol MovieViewDelegate;

@interface RestaurantTableViewController ()<Sample3TableViewCellDelegate>
@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *goodnum_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, copy) NSMutableArray *picture_;
@property (nonatomic, copy) NSMutableArray *movie_;
//@property (nonatomic, copy) NSMutableArray *review_;
@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSMutableArray *locality_;
@property (nonatomic, copy) NSMutableArray *thumbnail_;
@property (nonatomic, copy) NSMutableArray *starnum_;
@property (nonatomic, copy) NSMutableArray *commentnum_;
@property (nonatomic, retain) NSIndexPath *nowindexPath1;
@property (nonatomic, retain) NSIndexPath *nowindexPath2;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end


@implementation RestaurantTableViewController
{
    NSString *_text, *_hashTag;
}
@synthesize postRestName = _postRestName;
@synthesize headerLocality = _headerLocality;

-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag
{
    self = [super init];
    if (self) {
        _text = text;
        _hashTag = hashTag;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
    self.restname.text = _postRestName;
    self.locality.text = _headerLocality;
    // グローバル変数に保存
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    delegate.gText = _postRestName;

    [SVProgressHUD dismiss];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示

    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    [super viewWillDisappear:animated];
}

- (IBAction)unwindToTop:(UIStoryboardSegue *)segue
{
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
    //[moviePlayer stop];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
   
     self.navigationItem.title = _postRestName;
    
    //カスタムセルの導入
    UINib *nib = [UINib nibWithNibName:@"Sample3TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"restaurantTableViewCell"];
   
    //背景にイメージを追加したい
    //UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
     //self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    self.tableView.separatorColor = [UIColor clearColor ];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    
    // API からタイムラインのデータを取得
    [self _fetchRestaurant];

}


//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.85];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
    return [self.posts count];
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
    // スクロール開始
    CGPoint offset =  self.tableView.contentOffset;
    //スクロールポイントo
    CGPoint o = CGPointMake(183.0, 100.0 + offset.y);
    _nowindexPath1 = [self.tableView indexPathForRowAtPoint:o];
    NSLog(@"%ld", (long)_nowindexPath1.row);
    
    //[self updateVisibleCells];
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
        
    }
    // スクロール中は動画を停止する
    [[MoviePlayerManager sharedManager] scrolling:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // フリック操作によるスクロール終了
    [self endScroll];
    // [moviePlayer play];
     [self _playMovieAtCurrentCell];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        // ドラッグ終了 かつ 加速無し
        // [self endScroll];
        [self _playMovieAtCurrentCell];
        NSLog(@"scroll is stoped");
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // setContentOffset: 等によるスクロール終了
    [self endScroll];
    NSLog(@"scroll is stoped");
}

- (void)endScroll {
    //スクロール終了
    CGPoint offset =  self.tableView.contentOffset;
    CGPoint p = CGPointMake(183.0, 200.0 + offset.y);
    _nowindexPath2 = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"p:%ld", (long)_nowindexPath2.row);
   // [self updateVisibleCells];
    if(_nowindexPath1.row != _nowindexPath2.row){
        NSLog(@"現在oが%@でpが%@で前回スクロール時と異なっている",_nowindexPath1,_nowindexPath2);
    }
}





//1セルあたりの高さ
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 520.0;
}



// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}



- (void)handleTouchButton3:(UIButton *)sender event:(UIEvent *)event {
    
    //user nameタップ時の処理
    //[SVProgressHUD show];
    //[SVProgressHUD showWithStatus:@"移動中.." maskType:SVProgressHUDMaskTypeGradient];
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postUsername = [_user_name_ objectAtIndex:indexPath.row];
    _postPicture = [_picture_ objectAtIndex:indexPath.row];
    NSLog(@"確認：postUsername:%@",_postUsername);
    
    [self performSegueWithIdentifier:@"goOthersTimeline2" sender:self];
    NSLog(@"Username is touched");
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Do any additional setup after loading the view, typically from a nib.
    //storyboardで指定したIdentifierを指定する
    
    NSString *cellIdentifier = @"restaurantTableViewCell";
    Sample3TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
                 cell = [[Sample3TableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *buttontext = [_user_name_ objectAtIndex:indexPath.row];
    [cell.UsernameButton setTitle:buttontext forState:UIControlStateNormal];
    
    
    // セルにデータを反映
    RestaurantPost *post = self.posts[indexPath.row];
    [cell configureWithRestaurantPost:post];
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"didSelectRowAtIndex");
    //セグエで画面遷移する
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail2"]) {
        //ここでパラメータを渡す
        everyTableViewController *eveVC = segue.destinationViewController;
        eveVC.postID = _postID;
    }
        //プロフィール画面にパラメータを渡して遷移する
        if ([segue.identifier isEqualToString:@"goOthersTimeline2"]) {
            //ここでパラメータを渡す
            NSLog(@"ここは通った");
            usersTableViewController_other *useVC = segue.destinationViewController;
            useVC.postUsername = _postUsername;
            useVC.postPicture = _postPicture;
        }
    
}

- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapGoodWithPostID:(NSString *)postID
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
    [self _fetchRestaurant];
}

- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapCommentWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    [self performSegueWithIdentifier:@"showDetail2" sender:postID];
}

- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapNameWithusername:(NSString *)username
{
    //user nameタップの時の処理
    LOG(@"username=%@", username);
    _postUsername = username;
    NSLog(@"postUsername:%@",_postUsername);
    [self performSegueWithIdentifier:@"goOthersTimeline2" sender:self];
    NSLog(@"Username is touched");
    
}

- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapNameWithuserspicture:(NSString *)userspicture
{
    //user nameタップの時の処理②
    LOG(@"userspicture=%@", userspicture);
    _postPicture = userspicture;
    NSLog(@"postUsername:%@",_postPicture);
    //[self performSegueWithIdentifier:@"goOthersTimeline" sender:self];
    NSLog(@"Username is touched");
    
}


/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchRestaurant
{
    __weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSString *restName = _postRestName;
      [APIClient restaurantWithRestName:(NSString *)restName handler:^(id result, NSUInteger code, NSError *error) {
     
          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
          
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        
        // 取得したデータを self.posts に格納
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *post in result) {
            [tempPosts addObject:[RestaurantPost restaurantPostWithDictionary:post]];
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
    Sample3TableViewCell *currentCell = [self _currentCell];
    [[MoviePlayerManager sharedManager] scrolling:NO];
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:CGRectMake(0,
                                                                    currentCell.frame.size.height * [self _currentIndexPath].row + currentCell.thumbnailView.frame.origin.y+93,
                                                                    currentCell.thumbnailView.frame.size.width,
                                                                    currentCell.thumbnailView.frame.size.height)];
}

/**
 *  現在表示中のセルを取得
 *
 *  @return
 */
- (Sample3TableViewCell *)_currentCell
{
    return (Sample3TableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:[self _currentIndexPath]];
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
