//
//  TimelineTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "TimelineTableViewController.h"
#import "RecorderViewController.h"
#import "searchTableViewController.h"
#import "Sample2TableViewCell.h"
#import "everyTableViewController.h"
#import "SVProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking/AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "usersTableViewController.h"
#import "QuartzCore/QuartzCore.h"



@protocol MovieViewDelegate;

@interface TimelineTableViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *goodnum_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, copy) NSMutableArray *picture_;
@property (nonatomic, copy) NSMutableArray *movie_;
@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSMutableArray *review_;
@property (nonatomic, copy) NSMutableArray *commentnum_;
@property (nonatomic, copy) NSMutableArray *thumbnail_;
@property (nonatomic, copy) UIImageView *thumbPic;
@property (nonatomic, copy) NSMutableArray *starnum_;
@property (nonatomic, retain) NSIndexPath *nowindexPath;

@end

@implementation TimelineTableViewController


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
    NSString *timelineString = [NSString stringWithFormat:@"https://codelecture.com/gocci/timeline.php"];
    NSURL *url = [NSURL URLWithString:timelineString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
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
    //いいね数
    NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
    _goodnum_ = [goodnum mutableCopy];
    //レストラン名
    NSArray *restname = [jsonDic valueForKey:@"restname"];
    _restname_ = [restname mutableCopy];
    //コメント数
    NSArray *commentnum = [jsonDic valueForKey:@"comment_num"];
    _commentnum_ = [commentnum mutableCopy];
        NSLog(@"commentnum:%@",commentnum);
    //スターの数
    NSArray *starnum = [jsonDic valueForKey:@"star_evaluation"];
    _starnum_ = [starnum mutableCopy];
    NSLog(@"commentnum:%@",starnum);
        
        // 動画post_id
        NSArray *postid = [jsonDic valueForKey:@"post_id"];
        _postid_ = [postid mutableCopy];
        NSLog(@"postid:%@",_postid_);
        
    //サムネイル
    NSArray *thumbnail = [jsonDic valueForKey:@"thumbnail"];
    _thumbnail_ = [thumbnail mutableCopy];
        NSLog(@"thumbnail:%@",_thumbnail_);
        dispatch_async(q_main, ^{
        });
    });

        
    //JSONをパース
    NSString *reviewString = [NSString stringWithFormat:@"https://codelecture.com/gocci/submit/submit.php"];
    NSURL *reviewurl = [NSURL URLWithString:reviewString];
    NSString *reviewresponse = [NSString stringWithContentsOfURL:reviewurl encoding:NSUTF8StringEncoding error:nil];
    NSData *reviewjsonData = [reviewresponse dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *reviewjsonDic = [NSJSONSerialization JSONObjectWithData:reviewjsonData options:0 error:nil];
    dispatch_queue_t q2_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q2_main = dispatch_get_main_queue();
    dispatch_async(q2_global, ^{
    //レビュー
    NSArray *review = [reviewjsonDic valueForKey:@"review"];
    _review_ = [review mutableCopy];
        dispatch_async(q2_main, ^{
        });
    });
    
   [self.tableView reloadData];

    // update visible cells
    [self updateVisibleCells];
    [self.navigationItem setHidesBackButton:YES animated:NO];
     [SVProgressHUD dismiss];
    
}


-(void)viewWillDisappear:(BOOL)animated{
        [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
        [moviePlayer stop];
        [player stop];
        [moviePlayer.view removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
    [moviePlayer stop];
    [player stop];
    
    _cell.thumbnailView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
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

- (void)viewDidLoad
{
     [super viewDidLoad];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
   
    UINib *nib = [UINib nibWithNibName:@"Sample2TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TimelineTableViewCell"];
    
    self.tableView.bounces = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // スクロール開始
    CGPoint offset =  self.tableView.contentOffset;
    CGPoint p = CGPointMake(183.0, 485.0 + offset.y);
    _nowindexPath = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"%ld", (long)_nowindexPath.row);
    [moviePlayer pause];
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
 
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// フリック操作によるスクロール終了
	[self endScroll];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(!decelerate) {
		// ドラッグ終了 かつ 加速無し
    [self endScroll];
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
    CGPoint p = CGPointMake(183.0, 284.0 + offset.y);
    _nowindexPath = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"%ld", (long)_nowindexPath.row);
    [self updateVisibleCells];

    [moviePlayer play];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_restname_ count];
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 520.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    NSString *cellIdentifier = @"TimelineTableViewCell";
    _cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!_cell){
        _cell = [[Sample2TableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    

    NSString *dottext2 = [_thumbnail_ objectAtIndex:indexPath.row];
    // Here we use the new provided setImageWithURL: method to load the web image
    [_cell.thumbnailView  setImageWithURL:[NSURL URLWithString:dottext2]
                         placeholderImage:[UIImage imageNamed:@"yomikomi simple.png"]];
    
    
        // セルの更新メソッド
        [self updateCell:_cell atIndexPath:indexPath];
    
        return _cell ;
}


- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    
    //コメントボタンの時の処理
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"移動中.." maskType:SVProgressHUDMaskTypeGradient];
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    
    [self performSegueWithIdentifier:@"showDetail2" sender:self];
    NSLog(@"commentBtn is touched");
}


- (void)handleTouchButton2:(UIButton *)sender event:(UIEvent *)event {
    //いいねボタンの時の処理
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@",_postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"https://codelecture.com/gocci/goodinsert.php"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                                                       error:&error];
    
    dispatch_queue_t q1_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q1_main = dispatch_get_main_queue();
    dispatch_async(q1_global, ^{
        //JSONをパース
        NSString *timelineString = [NSString stringWithFormat:@"https://codelecture.com/gocci/timeline.php"];
        NSURL *url2 = [NSURL URLWithString:timelineString];
        NSString *response2 = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData2 = [response2 dataUsingEncoding:NSUTF32BigEndianStringEncoding];
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData2 options:0 error:nil];
        //いいね数
        NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
        _goodnum_ = [goodnum mutableCopy];
        //_cell.Goodnum.text= [_goodnum_ objectAtIndex:_nowindexPath];
        dispatch_async(q1_main, ^{
            [self.tableView reloadData];
        });
    });
    
    NSLog(@"goodBtn is touched");

}
/*
- (void)handleTouchButton3:(UIButton *)sender event:(UIEvent *)event {
    [_user_name_ removeAllObjects];
    [_restname_ removeAllObjects];
    [_picture_ removeAllObjects];
    [_goodnum_ removeAllObjects];
    [_starnum_ removeAllObjects];
    [_commentnum_ removeAllObjects];
    [_thumbnail_ removeAllObjects];
    [_movie_ removeAllObjects];
    [_review_ removeAllObjects];
    //削除ボタンの時の処理
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@",_postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"https://codelecture.com/gocci/delete.php"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                                                       error:&error];
    dispatch_queue_t q1_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q1_main = dispatch_get_main_queue();
    dispatch_async(q1_global, ^{
        //JSONをパース
        NSString *timelineString = [NSString stringWithFormat:@"https://codelecture.com/gocci/timeline.php"];
        NSURL *url2 = [NSURL URLWithString:timelineString];
        NSString *response2 = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData2 = [response2 dataUsingEncoding:NSUTF32BigEndianStringEncoding];
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData2 options:0 error:nil];
        // ユーザー名
        NSArray *user_name = [jsonDic valueForKey:@"user_name"];
        _user_name_ = [user_name mutableCopy];
        // プロフ画像
        NSArray *picture = [jsonDic valueForKey:@"picture"];
        _picture_ = [picture mutableCopy];
        // 動画URL
        NSArray *movie = [jsonDic valueForKey:@"movie"];
        _movie_ = [movie mutableCopy];
        //いいね数
        NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
        _goodnum_ = [goodnum mutableCopy];
        //レストラン名
        NSArray *restname = [jsonDic valueForKey:@"restname"];
        _restname_ = [restname mutableCopy];
        //コメント数
        NSArray *commentnum = [jsonDic valueForKey:@"comment_num"];
        _commentnum_ = [commentnum mutableCopy];
        NSLog(@"commentnum:%@",commentnum);
        //スターの数
        NSArray *starnum = [jsonDic valueForKey:@"star_evaluation"];
        _starnum_ = [starnum mutableCopy];
        NSLog(@"commentnum:%@",starnum);
        
        //サムネイル
        NSArray *thumbnail = [jsonDic valueForKey:@"thumbnail"];
        _thumbnail_ = [thumbnail mutableCopy];
        NSLog(@"thumbnail:%@",thumbnail);
        
        dispatch_async(q1_main, ^{
            [self.tableView reloadData];
        });
    });
    
    NSLog(@"goodBtn is touched");
}
 */


- (void)updateVisibleCells {
    //画面上に見えているセルの表示更新
    for (_cell in [self.tableView visibleCells]){
        [self updateCell:_cell atIndexPath:[self.tableView indexPathForCell:_cell]];
    }
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //updateした時の処理
    _cell.UsersName.text = [_user_name_ objectAtIndex:indexPath.row];
    _cell.RestaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    _cell.Review.text = [_review_ objectAtIndex:indexPath.row];
    _cell.Goodnum.text= [_goodnum_ objectAtIndex:indexPath.row];
    _cell.Commentnum.text = [_commentnum_ objectAtIndex:indexPath.row];
    _cell.Starnum.text = [_starnum_ objectAtIndex:indexPath.row];
    
    
    //コメントボタンのイベント
    [_cell.commentBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];

    //いいねボタンのイベント
    [_cell.goodBtn addTarget:self action:@selector(handleTouchButton2:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //削除ボタンのイベント
   // [_cell.deleteBtn addTarget:self action:@selector(handleTouchButton3:event:) forControlEvents:UIControlEventTouchUpInside];
   
    
    //ユーザーの画像を取得
    NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
    // Here we use the new provided setImageWithURL: method to load the web image
    [_cell.UsersPicture setImageWithURL:[NSURL URLWithString:dottext]
                   placeholderImage:[UIImage imageNamed:@"default.png"]];


    //動画再生
    NSString *text = [_movie_ objectAtIndex:_nowindexPath.row];
    NSURL *url = [NSURL URLWithString:text];
 
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;

    [moviePlayer.view setFrame:_cell.movieView.frame];
    [_cell.movieView addSubview: moviePlayer.view];
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


-(void)movieLoadStateDidChange:(id)sender{
    if(MPMovieLoadStatePlaythroughOK ) {
        NSLog(@"STATE CHANGED");
        
        //動画サムネイル画像のhidden
        _cell.thumbnailView.hidden = YES;
    }
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
        eveVC.postID = _postID;
    }
    
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    //繰り返し
    [moviePlayer play];
}


@end
