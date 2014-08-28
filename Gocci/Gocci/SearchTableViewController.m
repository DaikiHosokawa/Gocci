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

@interface SearchTableViewController ()<UISearchBarDelegate,CLLocationManagerDelegate>



@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *restaddress_;
@property (nonatomic, retain) NSMutableArray *meter_;
@property (nonatomic, retain) NSString *nowlat_;
@property (nonatomic, retain) NSString *nowlon_;


@end

@implementation SearchTableViewController

@synthesize locationManager;


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
    /*
    NSString *urlString = [NSString stringWithFormat:@"https://codelecture.com/gocci/?lat=35.8012&lon=139.183&limit=1"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"response:%@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSArray *venues = [[jsonDic objectForKey:@"response"] objectForKey:@"restname"];
    */
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     //AFNetworkingのテスト
     // AFHTTPSessionManagerを利用して、http://codecamp1353.lesson2.codecamp.jp/からJSONデータを取得する
     AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
     [manager GET:@"https://codelecture.com/gocci/?lat=35.8012&lon=139.183&limit=10"
     parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
     NSLog(@"response: %@", responseObject);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     NSLog(@"Error: %@", error);
     }];
    */
   
    
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
    
    // APIから返ってくるデータと仮定
    NSString *urlString = [NSString stringWithFormat:@"https://codelecture.com/gocci/?lat=%@&lon=%@&limit=30",_nowlat_,_nowlon_];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSArray *restname = [jsonDic valueForKey:@"restname"];
    _restname_ = [restname mutableCopy];
   
    // APIから返ってくるデータと仮定
    NSString *urlString2 = [NSString stringWithFormat:@"https://codelecture.com/gocci/?lat=%@&lon=%@&limit=30",_nowlat_,_nowlon_];
    NSURL *url2 = [NSURL URLWithString:urlString2];
    NSString *response2 = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData2 = [response2 dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic2 = [NSJSONSerialization JSONObjectWithData:jsonData2 options:0 error:nil];
    NSArray *restaddress = [jsonDic2 valueForKey:@"locality"];
    _restaddress_ = [restaddress mutableCopy];
   
    /*
    // APIから返ってくるデータと仮定
    NSString *urlString3 = [NSString stringWithFormat:@"https://codelecture.com/gocci/?lat=%@&lon=%@&limit=30",_nowlat_,_nowlon_];
    NSURL *url3 = [NSURL URLWithString:urlString3];
    NSString *response3 = [NSString stringWithContentsOfURL:url3 encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData3 = [response3 dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic3 = [NSJSONSerialization JSONObjectWithData:jsonData3 options:0 error:nil];
    NSArray *meter = [jsonDic3 valueForKey:@"distance"];
    _meter_ = [meter mutableCopy];
    */
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
    
    // 地図の中心座標に現在地を設定
    _mapView.centerCoordinate = _mapView.userLocation.location.coordinate;
    
    // 表示倍率の設定
    MKCoordinateRegion theRegion = _mapView.region;
    theRegion.span.longitudeDelta /= 500;
    theRegion.span.latitudeDelta /= 500;
    [_mapView setRegion:theRegion animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//テーブルセルの高さ
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}



//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.85];
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
    SampleTableViewCell* cell = (SampleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"searchTableViewCell"];
    if (cell == nil) {
        UINib* nib = [UINib nibWithNibName:@"searchTableViewCell" bundle:nil];
        NSArray* array = [nib instantiateWithOwner:nil options:nil];
        cell = [array objectAtIndex:0];
     }

    // Configure the cell.
    int r = rand();
    cell.restaurantName.text = [_restname_ objectAtIndex:indexPath.row];;
    cell.restaurantAddress.text = [_restaddress_ objectAtIndex:indexPath.row];
    cell.meter.text = [_meter_ objectAtIndex:indexPath.row];
    cell.logo.image = [UIImage imageNamed:
                            [NSString stringWithFormat:@"image%02ds.jpg", (r%8)+1]];
    NSLog(@"%@", [NSString stringWithFormat:@"image%02ds.jpg", (r%8)+1]);
     // Configure the cell...
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //セグエで画面遷移させる
    [self performSegueWithIdentifier:@"showDetail" sender:self.tableView];
}






@end
