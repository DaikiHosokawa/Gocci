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

@protocol MovieViewDelegate;

@interface RestaurantTableViewController ()

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
@property (nonatomic, copy) Sample3TableViewCell *cell;
@property (nonatomic, copy) NSMutableArray *commentnum_;
@property (nonatomic, retain) NSIndexPath *nowindexPath1;
@property (nonatomic, retain) NSIndexPath *nowindexPath2;


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
    
    //JSONをパース
    NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/restpage/?restname=%@",_postRestName];
    NSLog(@"restpage:%@",urlString);
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"jsonDic:%@", jsonDic);
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{
    // ユーザー名
    NSArray *user_name = [jsonDic valueForKey:@"user_name"];
    _user_name_ = [user_name mutableCopy];
    // プロフ画像
    NSArray *picture = [jsonDic valueForKey:@"picture"];
    _picture_ = [picture mutableCopy];
    // 動画URL
    NSArray *movie = [jsonDic valueForKey:@"movie"];
    _movie_ = [movie mutableCopy];
    NSLog(@"movie:%@",_movie_);
    // 住所
    NSArray *locality = [jsonDic valueForKey:@"locality"];
    _locality_ = [locality mutableCopy];
    
    /*
    //レビュー
    NSArray *review = [jsonDic valueForKey:@"review"];
    _review_ = [review mutableCopy];
    */
     
     //いいね数
    NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
    _goodnum_ = [goodnum mutableCopy];

    //レストラン名
    NSArray *restname = [jsonDic valueForKey:@"restname"];
    _restname_ = [restname mutableCopy];
    //画像URL
    NSArray *pictureurl = [jsonDic valueForKey:@"picture"];
    _picture_ = [pictureurl mutableCopy];
    // 動画post_id
    NSArray *postid = [jsonDic valueForKey:@"post_id"];
    _postid_ = [postid mutableCopy];
    // 動画post_id
    NSArray *starnum = [jsonDic valueForKey:@"star_evaluation"];
    _starnum_ = [starnum mutableCopy];
    //サムネイル
    NSArray *thumbnail = [jsonDic valueForKey:@"thumbnail"];
    _thumbnail_ = [thumbnail mutableCopy];

        //コメント数
        NSArray *commentnum = [jsonDic valueForKey:@"comment_num"];
        _commentnum_ = [commentnum mutableCopy];
        NSLog(@"commentnum:%@",commentnum);

    self.restname.text = _postRestName;
    self.locality.text = _headerLocality;
    // グローバル変数に保存
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    delegate.gText = _postRestName;
        dispatch_async(q_main, ^{
        });
    });
    [self updateVisibleCells];
    [SVProgressHUD dismiss];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
    [moviePlayer stop];
    [moviePlayer.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)unwindToTop:(UIStoryboardSegue *)segue
{
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
    [moviePlayer stop];
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
    //投稿が0の時の画面表示
    if([_movie_ count] == 0){
        
        NSLog(@"投稿がありません。");
        
        // UIImageViewの初期化
        CGRect rect = CGRectMake(30, 150, 250, 285);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        
        // 画像の読み込み
        imageView.image = [UIImage imageNamed:@"lion huki iro.png"];
        
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView];
        
    }

    // Return the number of rows in the section.
    return [_restname_ count];
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
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // フリック操作によるスクロール終了
    [self endScroll];
     [moviePlayer play];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        // ドラッグ終了 かつ 加速無し
        // [self endScroll];
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
    [self updateVisibleCells];
    if(_nowindexPath1.row != _nowindexPath2.row){
        NSLog(@"現在oが%@でpが%@で前回スクロール時と異なっている",_nowindexPath1,_nowindexPath2);
    }
}





//1セルあたりの高さ
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 520.0;
}

//////////////////////////コメントボタンの時の処理//////////////////////////

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"移動中.." maskType:SVProgressHUDMaskTypeGradient];
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    
    [self performSegueWithIdentifier:@"showDetail2" sender:self];
    NSLog(@"commentBtn is touched");
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

//////////////////////////Goodボタンの時の処理//////////////////////////
- (void)handleTouchButton2:(UIButton *)sender event:(UIEvent *)event {
    //このSegueに付けたIdentifierから遷移を呼び出すことができます
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@",_postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/goodinsert/"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                      
                                                       error:&error];
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{

    //JSONをパース
    NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/restpage/?restname=%@",_postRestName];
    NSLog(@"restpage:%@",urlString);
    NSURL *url2 = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSString *response2 = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData2 = [response2 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error2 =nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData2
                                                            options:NSJSONReadingMutableLeaves error:&error2];
    NSLog(@"jsonDic:%@", jsonDic);
    
        //いいね数
        NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
        _goodnum_ = [goodnum mutableCopy];
         dispatch_async(q_main, ^{
        [self.tableView reloadData];
         NSLog(@"goodBtn is touched");
                    });
    });
    
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

// 画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    //画面上に見えているセルの表示更新
    for (_cell in [self.tableView visibleCells]){
        [self updateCell:_cell atIndexPath:[self.tableView indexPathForCell:_cell]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Do any additional setup after loading the view, typically from a nib.
    //storyboardで指定したIdentifierを指定する
    
      NSString *cellIdentifier = @"restaurantTableViewCell";
    _cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!_cell){
        _cell = [[Sample3TableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *buttontext = [_user_name_ objectAtIndex:indexPath.row];
    [_cell.UsernameButton setTitle:buttontext forState:UIControlStateNormal];
    //user nameタップのイベント
    [_cell.UsernameButton addTarget:self action:@selector(handleTouchButton3:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //ユーザーの画像を取得
    NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
    // Here we use the new provided setImageWithURL: method to load the web image
    [_cell.UsersPicture setImageWithURL:[NSURL URLWithString:dottext]
                       placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    // セルの更新
    [self updateCell:_cell atIndexPath:indexPath];
 
    return _cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //updateした時の処理
    
    NSString *startext = [_starnum_ objectAtIndex:indexPath.row];
    // 文字列をNSIntegerに変換
    NSInteger inted = startext.integerValue;
    NSLog(@"文字列→NSInteger:%ld", inted);
    switch(inted){
        case 1:
        {
            UIImage *image = [UIImage imageNamed:@"star_green1.png"];
            _cell.starImage.image = image;
            break;
        }
            
        case 2:
        {
            UIImage *image = [UIImage imageNamed:@"star_green2.png"];
            _cell.starImage.image = image;
            break;
        }
        case 3:
        {
            UIImage *image = [UIImage imageNamed:@"star_green3.png"];
            _cell.starImage.image = image;
            break;
        }
        case 4:
        {
            UIImage *image = [UIImage imageNamed:@"star_green4.png"];
            _cell.starImage.image = image;
            break;
        }
        case 5:
        {
            UIImage *image = [UIImage imageNamed:@"star_green5.png"];
            _cell.starImage.image = image;
            break;
        }
        default:
        {
            UIImage *image = [UIImage imageNamed:@"star_green5.png"];
            _cell.starImage.image = image;
            break;
        }
    }
    
    //updateした時の処理
    _cell.RestaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    //_cell.Review.text = [_review_ objectAtIndex:indexPath.row];
    _cell.Goodnum.text= [_goodnum_ objectAtIndex:indexPath.row];
    _cell.Commentnum.text = [_commentnum_ objectAtIndex:indexPath.row];

    //コメントボタンのイベント
    [_cell.commentBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //いいねボタンのイベント
    [_cell.goodBtn addTarget:self action:@selector(handleTouchButton2:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //動画再生
    NSString *text = [_movie_ objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:text];
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //[moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    CGRect frame = CGRectMake(0, 60, 340, 340);
    
    [moviePlayer.view setFrame:frame];
    //[moviePlayer.view setFrame:_cell.movieView.frame];
    [_cell.contentView addSubview: moviePlayer.view];
    [_cell.contentView bringSubviewToFront:moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer prepareToPlay];
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

-(void)movieLoadStateDidChange:(id)sender{
    if(MPMovieLoadStatePlaythroughOK ) {
        NSLog(@"STATE CHANGED");
        //動画サムネイル画像のhidden
        dispatch_async(dispatch_get_main_queue(), ^{
            _cell.thumbnailView.hidden = YES;
        });
    }
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [moviePlayer play];
}


@end
