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
#import <Parse/Parse.h>
#import "Sample2TableViewCell.h"
#import "everyTableViewController.h"


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
@property (nonatomic, copy) NSMutableArray *review_;
@property (nonatomic, copy) Sample2TableViewCell *cell;


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
    NSLog(@"Timeline Api:%@",timelineString);
    NSURL *url = [NSURL URLWithString:timelineString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];

    // ユーザー名
    NSArray *user_name = [jsonDic valueForKey:@"user_name"];
    _user_name_ = [user_name mutableCopy];
    // プロフ画像
    NSArray *picture = [jsonDic valueForKey:@"picture"];
    _picture_ = [picture mutableCopy];
    // 動画URL
    NSArray *movie = [jsonDic valueForKey:@"movie"];
    _movie_ = [movie mutableCopy];
    //コメント
    NSArray *review = [jsonDic valueForKey:@"review"];
    _review_ = [review mutableCopy];
    //いいね数
    NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
    _goodnum_ = [goodnum mutableCopy];
    //レストラン名
    NSArray *restname = [jsonDic valueForKey:@"restname"];
    _restname_ = [restname mutableCopy];
    //動画URL
    NSArray *movieurl = [jsonDic valueForKey:@"movie"];
    _movie_ = [movieurl mutableCopy];
    //画像URL
    NSArray *pictureurl = [jsonDic valueForKey:@"picture"];
    _picture_ = [pictureurl mutableCopy];
    
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
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
   
    //self.optionIndices = [NSMutableIndexSet indexSetWithIndex:1];*メニューのメソッド
    UINib *nib = [UINib nibWithNibName:@"Sample2TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TimelineTableViewCell"];
    
    //背景にイメージを追加したい
    UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    locationManager = [[CLLocationManager alloc] init];
    
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
    
}


- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [moviePlayer play];
}

//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.85];
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


//セルの高さを調整
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 500.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _cell = (Sample2TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TimelineTableViewCell"];
    // Update Cell
    [self updateCell:cell atIndexPath:indexPath];
    //コメントボタンのイベント
    [_cell.commentBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    //言い値ボタンのイベント
    [_cell.goodBtn addTarget:self action:@selector(handleTouchButton2:event:) forControlEvents:UIControlEventTouchUpInside];
     
    // Configure the cell...
     return _cell ;

}

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    //このSegueに付けたIdentifierから遷移を呼び出すことができます
    /*
    everyTableViewController *eveVC = [self.storyboard instantiateViewControllerWithIdentifier:@"evTable"];
    [self presentViewController:eveVC animated:YES completion:nil];
   */
     [self performSegueWithIdentifier:@"showDetail2" sender:self];
    NSLog(@"commentBtn is touched");
}

- (void)handleTouchButton2:(UIButton *)sender event:(UIEvent *)event {
    //このSegueに付けたIdentifierから遷移を呼び出すことができます
    /*
     everyTableViewController *eveVC = [self.storyboard instantiateViewControllerWithIdentifier:@"evTable"];
     [self presentViewController:eveVC animated:YES completion:nil];
     */
    [self performSegueWithIdentifier:@"showDetail2" sender:self];
    NSLog(@"goodBtn is touched");
}


// 画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    for (UITableViewCell *cell in [self.tableView visibleCells]){
        [self updateCell:_cell atIndexPath:[self.tableView indexPathForCell:_cell]];
    }
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Update Cells
    
    NSString *text = [_movie_ objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:text];
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    moviePlayer.useApplicationAudioSession = YES;
    //_cell.movieView = moviePlayer.view;
    CGRect frame = _cell.movieView.frame;
    [moviePlayer.view setFrame:frame];
    [_cell.movieView addSubview: moviePlayer.view];
    [_cell.movieView bringSubviewToFront:moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    //[NSThread sleepForTimeInterval:1.0f];
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer prepareToPlay];
    [moviePlayer play];
    
    
    
	// Do any additional setup after loading the view, typically from a nib.
    //storyboardで指定したIdentifierを指定する
    
    
    // Configure the cell.
    _cell.UsersName.text = [_user_name_ objectAtIndex:indexPath.row];
    _cell.RestaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    _cell.Review.text = [_review_ objectAtIndex:indexPath.row];
    _cell.Review.textAlignment = UITextAlignmentLeft;
    _cell.Review.numberOfLines = 2;
    _cell.Goodnum.text= [_goodnum_ objectAtIndex:indexPath.row];
    
    //文字を取得
    NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
    NSURL *doturl = [NSURL URLWithString:dottext];
    NSData *data = [NSData dataWithContentsOfURL:doturl];
    UIImage *dotimage = [[UIImage alloc] initWithData:data];
    _cell.UsersPicture.image = dotimage;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    //セグエで画面遷移させる
    [self performSegueWithIdentifier:@"showDetail2" sender:self.tableView];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"searchSegue"]){
        SearchTableViewController *seaVC = [segue destinationViewController];
        seaVC.lon = _lon;
        seaVC.lat = _lat;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //一番下までスクロールしたかどうか
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
        //ここで次に表示する件数を取得して表示更新の処理を書けばOK
    }
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
