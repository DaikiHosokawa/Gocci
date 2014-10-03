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



@protocol MovieViewDelegate;

@interface TimelineTableViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableIndexSet *optionIndices;
@property (nonatomic, retain) NSString *lat;
@property (nonatomic, retain) NSString *lon;
@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *goodnum_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, copy) NSMutableArray *picture_;
@property (nonatomic, copy) NSMutableArray *movie_;
@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSMutableArray *review_;
@property (nonatomic, copy) NSMutableArray *commentnum_;
@property (nonatomic, copy) Sample2TableViewCell *cell;
@property (nonatomic, copy) UIImageView *thumbnailView;
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
        
        dispatch_async(q_main, ^{
        });
　　　});

        
    //JSONをパース
    NSString *postidString = [NSString stringWithFormat:@"https://codelecture.com/gocci/postid.php"];
    NSURL *postidurl = [NSURL URLWithString:postidString];
    NSString *postidresponse = [NSString stringWithContentsOfURL:postidurl encoding:NSUTF8StringEncoding error:nil];
    NSData *postidjsonData = [postidresponse dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *postidjsonDic = [NSJSONSerialization JSONObjectWithData:postidjsonData options:0 error:nil];
    
    dispatch_queue_t q1_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q1_main = dispatch_get_main_queue();
    dispatch_async(q1_global, ^{
    // 動画post_id
    NSArray *postid = [postidjsonDic valueForKey:@"post_id"];
    _postid_ = [postid mutableCopy];
        dispatch_async(q1_main, ^{
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
}
- (void)didReceiveMemoryWarning
{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
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
    
    locationManager = [[CLLocationManager alloc] init];
    
  /*
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        // 更新頻度(メートル)
        locationManager.distanceFilter = 20;
        // 取得精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 測位開始
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services not available.");
    }
   */
    
 // iOS8の対応
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        locationManager.delegate = self;
        // 更新頻度(メートル)
        locationManager.distanceFilter = 20;
        // 取得精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 測位開始
        [locationManager startUpdatingLocation];

        // 位置情報測位の許可を求めるメッセージを表示する
        [_locationManager requestAlwaysAuthorization]; // 常に許可
       // [_locationManager requestWhenInUseAuthorization]; // 使用中のみ許可
        
    } else { // iOS7以前
        locationManager.delegate = self;
        // 更新頻度(メートル)
        locationManager.distanceFilter = 20;
        // 取得精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 測位開始
        [locationManager startUpdatingLocation];

        // 位置測位スタート
        [_locationManager startUpdatingLocation];
        
    }
}
//////////////////////////リピート処理//////////////////////////
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [moviePlayer play];
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    // 位置情報を取り出す
    //緯度
    latitude = newLocation.coordinate.latitude;
    //経度
    longitude = newLocation.coordinate.longitude;
    _lat = [NSString stringWithFormat:@"%f", latitude];
    _lon = [NSString stringWithFormat:@"%f", longitude];
    NSLog(@"lat:%@",_lat);
    NSLog(@"lon:%@",_lon);
    [self.locationManager stopUpdatingLocation];
}


- (void)endScroll {
　　//スクロール終了
    CGPoint offset =  self.tableView.contentOffset;
    CGPoint p = CGPointMake(183.0, 284.0 + offset.y);
    _nowindexPath = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"%ld", (long)_nowindexPath.row);
   [self updateVisibleCells];
    //_thumbnailView.hidden = YES;
    [moviePlayer play];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // スクロール開始
    CGPoint offset =  self.tableView.contentOffset;
    
    CGPoint p = CGPointMake(183.0, 284.0 + offset.y);
    
    _nowindexPath = [self.tableView indexPathForRowAtPoint:p];
    
    NSLog(@"%ld", (long)_nowindexPath.row);
    
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
 
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_movie_ count];
}




////////////////////////////セルの高さを調整//////////////////////////
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 520.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    _cell = (Sample2TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TimelineTableViewCell"];
 
        // セルの更新
        [self updateCell:cell atIndexPath:indexPath];
        //コメントボタンのイベント
        [_cell.commentBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
        //いいねボタンのイベント
        [_cell.goodBtn addTarget:self action:@selector(handleTouchButton2:event:) forControlEvents:UIControlEventTouchUpInside];
    
       //ユーザーの画像を取得
        NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
        NSURL *doturl = [NSURL URLWithString:dottext];
        NSData *data = [NSData dataWithContentsOfURL:doturl];
        UIImage *dotimage = [[UIImage alloc] initWithData:data];
        _cell.UsersPicture.image = dotimage;
        NSError *activationError = nil;
    
        [[AVAudioSession sharedInstance] setActive: NO error:&activationError];
        [_cell layoutSubviews];
        // Configure the cell...
    return _cell ;

}

//画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    for (_cell in [self.tableView visibleCells]){
        [self updateCell:_cell atIndexPath:[self.tableView indexPathForCell:_cell]];
    }
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

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
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







- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //updateした時の処理
    _cell.UsersName.text = [_user_name_ objectAtIndex:indexPath.row];
    _cell.RestaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    _cell.UsersName.textAlignment =  NSTextAlignmentLeft;
    _cell.Review.text = [_review_ objectAtIndex:indexPath.row];
    _cell.Review.textAlignment =  NSTextAlignmentLeft;
    _cell.Review.numberOfLines = 2;
    _cell.Goodnum.text= [_goodnum_ objectAtIndex:indexPath.row];
    _cell.Goodnum.textAlignment = NSTextAlignmentLeft;
    _cell.Commentnum.text = [_commentnum_ objectAtIndex:indexPath.row];
    _cell.Commentnum.textAlignment = NSTextAlignmentLeft;
    
    
    //動画再生
    NSString *text = [_movie_ objectAtIndex:_nowindexPath.row];
    NSURL *url = [NSURL URLWithString:text];
 
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    CGRect frame = _cell.movieView.frame;
    [moviePlayer.view setFrame:frame];
    [_cell.movieView addSubview: moviePlayer.view];
    [_cell.contentView bringSubviewToFront:moviePlayer.view];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer prepareToPlay];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    //セグエで画面遷移させる
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   
    if ([[segue identifier] isEqualToString:@"searchSegue"]){
        SearchTableViewController *seaVC = [segue destinationViewController];
        seaVC.lon = _lon;
        seaVC.lat = _lat;
        
        [SVProgressHUD show];
        [SVProgressHUD showWithStatus:@"移動中です" maskType:SVProgressHUDMaskTypeGradient];

    }
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail2"]) {
        //ここでパラメータを渡す
        everyTableViewController *eveVC = segue.destinationViewController;
        eveVC.postID = _postID;
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{//iOS8対応
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        // 位置測位スタート
        [_locationManager startUpdatingLocation];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            // ユーザが位置情報の使用を許可していない
            [_locationManager requestAlwaysAuthorization]; // 常に許可
        }

    }
}



@end
