//
//  SearchTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "SearchTableViewController.h"
#import "RestaurantTableViewController.h"
#import "SearchCell.h"
#import "CustomAnnotation.h"
#import "AppDelegate.h"
#import "MoviePlayerManager.h"
#import "DemoContentView.h"
#import "APIClient.h"
#import "Restaurant.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "CXCardView.h"
#import "LocationClient.h"
#import <GoogleMaps/GoogleMaps.h>

@import MapKit;
@import CoreLocation;

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";

@interface SearchTableViewController ()
<UISearchBarDelegate, UISearchBarDelegate, MKMapViewDelegate, SearchCellDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
}

- (void)showDefaultContentView;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *dontexist;
@property (nonatomic, assign) BOOL showedUserLocation;

@property (nonatomic, copy) NSArray *restaurants;
@property (nonatomic, copy) NSArray *annotations;
@property (nonatomic) BOOL searched;
@property (nonatomic, strong) CLLocation *fetchedLocation;

@property (nonatomic, strong) UIRefreshControl *refresh;

@end

@implementation SearchTableViewController

#pragma mark - アイテム名登録用
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restaurants = [NSArray array];
    self.annotations = [NSArray array];
    self.searched = NO;
     self.tableView.bounces = NO;
    
    // Pull to refresh
    self.refresh = [UIRefreshControl new];
    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
    
    //4.7inch対応
    CGRect rect2 = [UIScreen mainScreen].bounds;
    if (rect2.size.height == 667) {
        self.showedUserLocation = NO;
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.frame = CGRectMake(0, 0, 375, 315);
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        
        [self.view addSubview:_mapView];
    }
    else if (rect2.size.height == 736) {
        self.showedUserLocation = NO;
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.frame = CGRectMake(0, 0, 414, 315);
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        [self.view addSubview:_mapView];
    }else{
        // 地図の表示
        self.showedUserLocation = NO;
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.frame = CGRectMake(0, 0, 320, 315);
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        [self.view addSubview:_mapView];
    }
    
	// !!!:dezamisystem
//	self.navigationItem.backBarButtonItem = backButton;
	
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.tintColor = [UIColor darkGrayColor];
    _searchBar.placeholder = @"検索";
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;  
    // UINavigationBar上に、UISearchBarを追加
#if 1
	self.navigationItem.titleView = _searchBar;
	self.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 44);
#else
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
#endif

    // Table View の設定
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil]
         forCellReuseIdentifier:SearchCellIdentifier];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
 
    _searchBar.text = nil;
    
    __weak typeof(self)weakSelf = self;
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error) {
        if (error) {
            LOG(@"位置情報の取得に失敗 / error=%@", error);
            return;
        }
        
        weakSelf.fetchedLocation = location;
        
        // 画面を表示した初回の一回のみ、現在地を中心にしたレストラン一覧を取得する
        static dispatch_once_t searchCurrentLocationOnceToken;
        dispatch_once(&searchCurrentLocationOnceToken, ^{
            [weakSelf _fetchFirstRestaurantsWithCoordinate:location.coordinate];
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
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
    [_searchBar resignFirstResponder];
    _dontexist.text = nil;

    [self _searchRestaurants:searchBar.text];
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
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
         descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.];
        descriptionLabel.text = @"近くの美味しいお店が探せます";
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 現在位置の画像は置き換えない
    if (annotation.coordinate.latitude == mapView.userLocation.coordinate.latitude &&
        annotation.coordinate.longitude == mapView.userLocation.coordinate.longitude) {
        return nil;
    }
    
    // 検索結果のピン画像を pin.png に変更
    NSString *identifier = @"SearchPin";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.image = [UIImage imageNamed:@"pin"];
        annotationView.canShowCallout = YES;
    }
    
    return annotationView;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.restaurants count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SearchCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCell *cell = (SearchCell *)[tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
    if (!cell) {
        cell = [SearchCell cell];
    }

    Restaurant *restaurant = self.restaurants[indexPath.row];
    [cell configureWithRestaurant:restaurant index:indexPath.row];
    cell.delegate = self;
    
     [SVProgressHUD dismiss];
    
    return cell;
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

#pragma mark - Segue
#pragma mark 遷移前準備
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 2つ目の画面にパラメータを渡して遷移する
//    if ([segue.identifier isEqualToString:@"showDetail"])
	if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
	{
        // ここでパラメータを渡す
        NSDictionary *params = (NSDictionary *)sender;
        NSLog(@"params:%@",params);
        RestaurantTableViewController *restVC = segue.destinationViewController;
        restVC.postRestName = params[@"rest_name"];
        restVC.postLocality = params[@"header_locality"];
        restVC.postTell = params[@"tell"];
        restVC.postHomepage = params[@"homepage"];
        restVC.postCategory = params[@"category"];
        
    }
}


#pragma mark - SearchCell Delegate

- (void)searchCell:(SearchCell *)cell shouldShowMapAtIndex:(NSUInteger)index
{
    Restaurant *restaurant = self.restaurants[index];
    NSString *mapText = restaurant.restname;
    NSString *mapText2 = restaurant.locality;
    mapText = [mapText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    mapText2  = [mapText2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *directions = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@&zoom=18",mapText2];
    NSLog(@"URLSchemes:%@",directions);
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:directions]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
        //アラート出す
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ナビゲーション使用にはGoogleMapのアプリが必要です"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)searchCell:(SearchCell *)cell shouldDetailAtIndex:(NSUInteger)index
{
    Restaurant *restaurant = self.restaurants[index];
    
    [self performSegueWithIdentifier:SEGUE_GO_RESTAURANT
                              sender:@{
                                       @"rest_name": restaurant.restname,
                                       @"header_locality": restaurant.locality,
                                       @"post_lat": [NSString stringWithFormat:@"%@", @(restaurant.lat)],
                                       @"post_lon": [NSString stringWithFormat:@"%@", @(restaurant.lon)],
                                       @"tell": restaurant.tel,
                                       @"homepage": restaurant.homepage,
                                       @"category" : restaurant.category,
                                       }];
}

- (void)searchCell:(SearchCell *)cell shouldDetailAtIndex2:(NSUInteger)index
{
    Restaurant *restaurant = self.restaurants[index];
    
    [self performSegueWithIdentifier:SEGUE_GO_RESTAURANT
                              sender:@{
                                       @"rest_name": restaurant.restname,
                                       @"header_locality": restaurant.locality,
                                       @"post_lat": [NSString stringWithFormat:@"%@", @(restaurant.lat)],
                                       @"post_lon": [NSString stringWithFormat:@"%@", @(restaurant.lon)],
                                       @"tell": restaurant.tel,
                                       @"homepage": restaurant.homepage,
                                       @"category" : restaurant.category,
                                       }];
}


#pragma mark - Private Methods

/**
 *  初回のレストラン一覧を取得
 *
 *  @param coordinate 検索する緯度・軽度
 */
- (void)_fetchFirstRestaurantsWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    LOG(@"lat=%@, lng=%@", @(coordinate.latitude), @(coordinate.longitude));

    // 既に検索をしている場合は、現在地中心のレストラン一覧の取得は行わない
    if (self.searched) {
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [weakSelf.refresh beginRefreshing];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [APIClient distWithLatitude:coordinate.latitude
                      longitude:coordinate.longitude
                          limit:30
                        handler:^(id result, NSUInteger code, NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         if ([weakSelf.refresh isRefreshing]) {
             [weakSelf.refresh endRefreshing];
         }
         
         
         if (!result || error) {
             // TODO: エラーメッセージを掲出
             return;
         }
         
         if (weakSelf.searched) {
             return;
         }
         
         [weakSelf _reloadRestaurants:result];
         
         if ([self.restaurants count] == 0) {
             LOG(@"投稿がない");
             _emptyView.hidden = NO;
              [SVProgressHUD dismiss];
         }
     } useCache:^(id cachedResult)
     {
         if (!cachedResult) {
             return;
         }
         
         if (weakSelf.searched) {
             return;
         }
         
         [weakSelf _reloadRestaurants:cachedResult];
     }];
}

/**
 *  レストランを検索
 *
 *  @param searchText 検索文字列
 */
- (void)_searchRestaurants:(NSString *)searchText
{
    [SVProgressHUD show];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    [APIClient searchWithRestName:searchText
                         latitude:self.fetchedLocation.coordinate.latitude
                        longitude:self.fetchedLocation.coordinate.longitude
                            limit:30
                          handler:^(id result, NSUInteger code, NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         if (!result || error) {
             // TODO: エラーメッセージを掲出
             return;
         }
         
         weakSelf.searched = YES;
         
         LOG(@"result=%@",result);
         
         [weakSelf _reloadRestaurants:result];
     }];
}

/**
 *  レストラン一覧を更新
 *
 *  @param result API からの取得結果
 */
- (void)_reloadRestaurants:(NSArray *)result
{
    [SVProgressHUD show];
    
    NSMutableArray *tempRestaurants = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in (NSArray *)result) {
        [tempRestaurants addObject:[Restaurant restaurantWithDictionary:dict]];
    }
    self.restaurants = [NSArray arrayWithArray:tempRestaurants];
    
    // 投稿がない場合
    if ([self.restaurants count] == 0) {
        if (_dontexist) {
            [_dontexist removeFromSuperview];
            _dontexist = nil;
        }
        /*
        _dontexist = [[UILabel alloc] init];
        _dontexist.frame = CGRectMake(30, 250, 250, 330);
        [_dontexist setText:[NSString stringWithFormat:@"キーワード「%@」に該当する店舗はありません。",_searchBar.text]];
        _dontexist.numberOfLines = 3;
        _dontexist.textAlignment = NSTextAlignmentLeft;
        */
        [self.view addSubview:_dontexist];
    } else {
        [_dontexist removeFromSuperview];
        _dontexist = nil;
    }
    
    // ピンを設置
    [self.mapView removeAnnotations:self.annotations];
    NSMutableArray *tempAnnotations = [NSMutableArray arrayWithCapacity:0];
    for (Restaurant *restaurant in self.restaurants) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(restaurant.lat, restaurant.lon);
        CustomAnnotation *annotation = [[CustomAnnotation alloc]initWithLocationCoordinate:coordinate
                                                                                     title:restaurant.restname
                                                                                  subtitle:restaurant.category];
        [self.mapView addAnnotation:annotation];
        [tempAnnotations addObject:annotation];
    }
    self.annotations = [NSArray arrayWithArray:tempAnnotations];
    // 取得した座標を中心に地図を表示
    MKCoordinateRegion zoom = _mapView.region;
    // どのくらいの範囲までズームするか。※値が小さいほどズームします
    zoom.span.latitudeDelta = 0.001;
    zoom.span.longitudeDelta = 0.001;
    // ズームする
    [self.mapView setRegion:zoom animated: YES];

    // ピンが全て見えるように地図のズームレベルを調整
    //[self.mapView showAnnotations:self.annotations animated:YES];
    
    [self.tableView reloadData];
}

- (void)refresh:(UIRefreshControl *)sender
{
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         [self _fetchFirstRestaurantsWithCoordinate:location.coordinate];
     }];
}

@end
