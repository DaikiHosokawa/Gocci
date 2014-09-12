//
//  SearchTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "SearchTableViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "SampleTableViewCell.h"
#import "RestaurantTableViewController.h"

@interface SearchTableViewController ()<UISearchBarDelegate,CLLocationManagerDelegate>


@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *category_;
@property (nonatomic, retain) NSMutableArray *meter_;
@property (nonatomic, copy) NSMutableArray *jsonlat_;
@property (nonatomic, copy) NSMutableArray *jsonlon_;
@property (nonatomic, retain) NSMutableArray *restaddress_;
@property (nonatomic, retain) NSString *nowlat_;
@property (nonatomic, retain) NSString *nowlon_;
@property (nonatomic, copy) SampleTableViewCell *cell;

@end

@implementation SearchTableViewController

@synthesize locationManager;
@synthesize lat;
@synthesize lon;


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
  
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager stopUpdatingLocation]; //測位停止
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    // 地図の表示
    _mapView = [[MKMapView alloc] init];
    
    _mapView.frame = CGRectMake(0, 0, 320, 200);
    _mapView.mapType = MKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    [_mapView.userLocation addObserver:self
                            forKeyPath:@"location"
                               options:0
                               context:NULL];
    
    
    //カスタムセルの導入
    UINib *nib = [UINib nibWithNibName:@"SampleTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"searchTableViewCell"];
    
    

    //サーチバーの作成
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.tintColor = [UIColor blackColor];
    searchBar.placeholder = @"キーワードを入力して下さい";
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.delegate = self;
    searchBar.showsSearchResultsButton = YES;
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    
    // UINavigationBar上に、UISearchBarを追加
    self.navigationItem.titleView = searchBar;
    self.navigationItem.titleView.frame = CGRectMake(0, 0   , 0, 0);
    [self.view addSubview: searchBar];
    
    
    //背景にイメージを追加したい
    UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.tableView.bounces = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    locationManager = [[CLLocationManager alloc] init];
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self; // ……【1】
        // 更新頻度(メートル)
        locationManager.distanceFilter = 20;
        // 取得精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 測位開始
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services not available.");
    }
    
    
    //JSONをパース
    NSString *urlString = [NSString stringWithFormat:@"https://codelecture.com/gocci/?lat=%@&lon=%@&limit=30",lat,lon];
    NSLog(@"urlStringatnoulon:%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSLog(@"jsonData:%@",jsonData);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"jsonDic:%@",jsonDic);
    
    // 飲食店名
    NSArray *restname = [jsonDic valueForKey:@"restname"];
    _restname_ = [restname mutableCopy];
    // 店舗カテゴリー
    NSArray *category = [jsonDic valueForKey:@"category"];
    _category_ = [category mutableCopy];
    // 距離
    NSArray *meter = [jsonDic valueForKey:@"distance"];
    _meter_ = [meter mutableCopy];
    // 店舗住所
    NSArray *restaddress = [jsonDic valueForKey:@"locality"];
    _restaddress_ = [restaddress mutableCopy];

    //緯度
    NSArray *jsonlat = [jsonDic valueForKey:@"lat"];
    _jsonlat_ = [jsonlat mutableCopy];
    //経度
    NSArray *jsonlon = [jsonDic valueForKey:@"lon"];
    _jsonlon_ = [jsonlon mutableCopy];
    
    //30本のピンを立てる
    for (int i=0; i<30; i++) {
        NSString *ni = _restname_[i];
        NSString *ai = _category_[i];
        double loi = [_jsonlon_[i]doubleValue];
        NSLog(@"lo:%f ",loi);
        double lai = [_jsonlat_[i]doubleValue];
        NSLog(@"la:%f",lai);
        [_mapView addAnnotation:
         [[CustomAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(lai, loi)
                                                       title:(@"%@",ni)
                                                    subtitle:(@"%@",ai)]];
    }
   }

// 位置情報更新時
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    // 位置情報を取り出す
    longitude = newLocation.coordinate.longitude;
    // doubleを文字列に変換
    _nowlon_ = [NSString stringWithFormat:@"%f", longitude];
    NSLog(@"nowlon:%@",_nowlon_);
    latitude = newLocation.coordinate.latitude;
    // doubleを文字列に変換
    _nowlat_ = [NSString stringWithFormat:@"%f", latitude];
    NSLog(@"nowlon:%@",_nowlat_);
  }

 
// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}

-(void) onResume {
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager startUpdatingLocation]; //測位再開
}

-(void) onPause {
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager stopUpdatingLocation]; //測位停止
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    [self onPause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [self onResume];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    // 表示倍率の設定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(_mapView.userLocation.coordinate, span);
    [_mapView setRegion:region animated:NO];
    //一度しか現在地に移動しないなら removeObserver する
    [_mapView.userLocation removeObserver:self forKeyPath:@"location"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//テーブルセルの高さ
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79.0;
}



//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.85];
}


- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    // UISearchBar からフォーカスを外します。
    [searchBar resignFirstResponder];
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
    return 30;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cell = (SampleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"searchTableViewCell"];
    // Configure the cell.
    _cell.restaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    _cell.restaurantAddress.text = [_restaddress_ objectAtIndex:indexPath.row];
    _cell.meter.text= [_meter_ objectAtIndex:indexPath.row];
    // イベントを付ける
    [_cell.selectBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
     // Configure the cell...
    return _cell;
}

#pragma mark - handleTouchEvent
- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %d was tapped.",indexPath.row);
    _postRestName = [_restname_ objectAtIndex:indexPath.row];
    NSLog(@"postRestName:%@",_postRestName);
    //ViewControllerからViewControllerへ関連付けたSegueにはIdentifierが設定できます。
    //このSegueに付けたIdentifierから遷移を呼び出すことができます。
    RestaurantTableViewController* restVC;
    restVC.postRestName = _postRestName;
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        //ここでパラメータを渡す
        RestaurantTableViewController *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestName;
    }
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //セグエで画面遷移させる
    [self performSegueWithIdentifier:@"showDetail" sender:self.tableView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}





@end
