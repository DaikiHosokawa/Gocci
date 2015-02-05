//
//  SearchTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "SearchTableViewController.h"
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "SampleTableViewCell.h"
#import "RestaurantTableViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "MoviePlayerManager.h"
#import "DemoContentView.h"

@interface SearchTableViewController ()
<UISearchBarDelegate, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
}

- (void)showDefaultContentView;


@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *restname_;
@property (nonatomic, strong) NSMutableArray *category_;
@property (nonatomic, strong) NSMutableArray *meter_;
@property (nonatomic, strong) NSMutableArray *jsonlat_;
@property (nonatomic, strong) NSMutableArray *jsonlon_;
@property (nonatomic, strong) NSMutableArray *restaddress_;
@property (nonatomic, strong) NSString *nowlat_;
@property (nonatomic, strong) NSString *nowlon_;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *dontexist;
@property (nonatomic, assign) BOOL showedUserLocation;

@end

@implementation SearchTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示

    _searchBar.text = NULL;
    AppDelegate *appDelegete = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    //dispatch_queue_t q2_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_queue_t q2_main = dispatch_get_main_queue();
    //dispatch_async(q2_global, ^{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 飲食店名
        NSArray *restname = [appDelegete.jsonDic valueForKey:@"restname"];
        _restname_ = [restname mutableCopy];
        // 店舗カテゴリー
        NSArray *category = [appDelegete.jsonDic valueForKey:@"category"];
        _category_ = [category mutableCopy];
        // 距離
        NSArray *meter = [appDelegete.jsonDic valueForKey:@"distance"];
        _meter_ = [meter mutableCopy];
        // 店舗住所
        NSArray *restaddress = [appDelegete.jsonDic valueForKey:@"locality"];
        _restaddress_ = [restaddress mutableCopy];
        
        //緯度
        NSArray *jsonlat = [appDelegete.jsonDic valueForKey:@"lat"];
        _jsonlat_ = [jsonlat mutableCopy];
        //経度
        NSArray *jsonlon = [appDelegete.jsonDic valueForKey:@"lon"];
        _jsonlon_ = [jsonlon mutableCopy];
        //dispatch_async(q2_main, ^{
            [self.tableView reloadData];
        //});
    });
    

    //30本のピンを立てる
    for (int i=0; i<30; i++) {
        NSString *ni = _restname_[i];
        NSString *ai = _category_[i];
        double loi = [_jsonlon_[i]doubleValue];
        NSLog(@"lo:%f ",loi);
        double lai = [_jsonlat_[i]doubleValue];
        NSLog(@"la:%f",lai);
        
        [_mapView addAnnotation: [[CustomAnnotation alloc]initWithLocationCoordinate:CLLocationCoordinate2DMake(lai, loi)
                                                                               title:ni
                                                                            subtitle:ai]];
        
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    //4.7inch対応
    CGRect rect2 = [UIScreen mainScreen].bounds;
    if (rect2.size.height == 667) {
        self.showedUserLocation = NO;
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.frame = CGRectMake(0, 0, 375, 200);
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        [self.view addSubview:_mapView];
    }
    else if (rect2.size.height == 736) {
        self.showedUserLocation = NO;
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.frame = CGRectMake(0, 0, 414, 200);
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        [self.view addSubview:_mapView];
    }else{
        // 地図の表示
        self.showedUserLocation = NO;
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.frame = CGRectMake(0, 0, 320, 200);
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        [self.view addSubview:_mapView];
    }
     //375
    //カスタムセルの導入
    UINib *nib = [UINib nibWithNibName:@"SampleTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"searchTableViewCell"];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.tintColor = [UIColor darkGrayColor];
    _searchBar.placeholder = @"検索";
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;

    
    // UINavigationBar上に、UISearchBarを追加
    self.navigationItem.titleView = _searchBar;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 44);
    
    self.locationManager = [[CLLocationManager alloc] init];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
        [self showDefaultContentView];
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_restaddress_ removeAllObjects];
    [_restname_ removeAllObjects];
    [_meter_ removeAllObjects];
    [_category_ removeAllObjects];
    [_searchBar resignFirstResponder];
    _dontexist.text = NULL;
    NSString *searchText = _searchBar.text;
    AppDelegate *appDelegete = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //JSONをパース
    NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/search/?restname=%@&lat=%@&lon=%@&limit=30",searchText,appDelegete.lat,appDelegete.lon];
    NSLog(@"urlStringatnoulon:%@",urlString);
    NSString *encodeString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodeString];
    NSLog(@"url:%@",url);
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"response:%@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSLog(@"jsonData:%@",jsonData);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"jsonDic:%@",jsonDic);
    
    dispatch_queue_t q2_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q2_main = dispatch_get_main_queue();
    dispatch_async(q2_global, ^{
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
                dispatch_async(q2_main, ^{
        [self.tableView reloadData];//テーブルの更新
                    //投稿が0の時の画面表示
                    if([_restname_ count] == 0){
                        
                        NSLog(@"投稿がありません。");
                        
                        // UIImageViewの初期化
                        _dontexist = [[UILabel alloc] init];
                        _dontexist.frame = CGRectMake(30, 200, 250, 280);
                        [_dontexist setText:[NSString stringWithFormat:@"キーワード「%@」に該当する店舗はありません。",_searchBar.text]];
                        _dontexist.numberOfLines = 3;
                        _dontexist.textAlignment = NSTextAlignmentLeft;
                        [self.view addSubview:_dontexist];
                        
                    }
        });
    });
}

- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate2"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate2"];
    // 保存
    [userDefaults synchronize];
    // 初回起動
    return YES;
}

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
        descriptionLabel.text = @"検索画面では近くのお店が探せます";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // 初回に現在地に移動している場合は再度移動しないようにする
    if (self.showedUserLocation) {
        return;
    }
    
    // 表示倍率の設定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
    [_mapView setRegion:region animated:NO];
    self.showedUserLocation = YES;
}


#pragma mark - UITableViewDelegate

//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.85];
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

//テーブルセルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SampleTableViewCell *cell = (SampleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"searchTableViewCell"];

    cell.restaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    cell.restaurantAddress.text = [_restaddress_ objectAtIndex:indexPath.row];
    cell.meter.text= [_meter_ objectAtIndex:indexPath.row];
    cell.meter.textAlignment = NSTextAlignmentRight;
    cell.categoryname.text = [_category_ objectAtIndex:indexPath.row];
    
    return cell;
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *postRestName = [_restname_ objectAtIndex:indexPath.row];
    NSString *headerLocality = [_restaddress_ objectAtIndex:indexPath.row];
    NSString *postLat = [_jsonlat_ objectAtIndex:indexPath.row];
    NSString *postLon = [_jsonlon_ objectAtIndex:indexPath.row];
    
    // セグエで画面遷移させる
    [self performSegueWithIdentifier:@"showDetail"
                              sender:@{
                                       @"rest_name": postRestName,
                                       @"header_locality": headerLocality,
                                       @"post_lat":postLat,
                                       @"post_lon":postLon
                                       }]; // prepareForSegue:sender: の sender に遷移に使うパラメータを渡す
    
    // 選択状態の解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        // ここでパラメータを渡す
        NSDictionary *params = (NSDictionary *)sender;
        RestaurantTableViewController *restVC = segue.destinationViewController;
        restVC.postRestName = params[@"rest_name"];
        restVC.headerLocality = params[@"header_locality"];
        restVC.postLon = params[@"post_lat"];
        NSLog(@"restVC.postLon:%@",restVC.postLon);
        restVC.postLat = params[@"post_lon"];
        NSLog(@"restVC.postLat:%@",restVC.postLat);
        
    }
}

@end
