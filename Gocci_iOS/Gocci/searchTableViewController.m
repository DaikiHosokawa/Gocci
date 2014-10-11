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

@interface SearchTableViewController ()<UISearchBarDelegate,CLLocationManagerDelegate,UISearchBarDelegate>


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
@property (nonatomic, copy) UISearchBar *searchBar;
@property (nonatomic, copy) UILabel *dontexist;

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
    _searchBar.text = NULL;
    AppDelegate *appDelegete = [[UIApplication sharedApplication] delegate];
    //JSONをパース
    NSString *urlString = [NSString stringWithFormat:@"https://codelecture.com/gocci/?lat=%@&lon=%@&limit=30",appDelegete.lat,appDelegete.lon];
    NSLog(@"urlStringatnoulon:%@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
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
    
    //緯度
    NSArray *jsonlat = [jsonDic valueForKey:@"lat"];
    _jsonlat_ = [jsonlat mutableCopy];
    //経度
    NSArray *jsonlon = [jsonDic valueForKey:@"lon"];
    _jsonlon_ = [jsonlon mutableCopy];
        dispatch_async(q2_main, ^{
            [self.tableView reloadData];
        });
    });
    

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
        
        [SVProgressHUD dismiss];
    }
       
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
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

    //背景にイメージを追加したい
   //UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
   // self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
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
    
    // 初期フォーカスを設定
    //[searchBar becomeFirstResponder];
    
    locationManager = [[CLLocationManager alloc] init];
    
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [_restaddress_ removeAllObjects];
    [_restname_ removeAllObjects];
    [_meter_ removeAllObjects];
    [_category_ removeAllObjects];
    [_searchBar resignFirstResponder];
    _dontexist.text = NULL;
    NSString *searchText = _searchBar.text;
    //JSONをパース
    NSString *urlString = [NSString stringWithFormat:@"https://codelecture.com/gocci/search.php?restname=%@",searchText];
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
    return 85.0;
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
    return [_restname_ count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cell = (SampleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"searchTableViewCell"];
    // Configure the cell.
    _cell.restaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    _cell.restaurantAddress.text = [_restaddress_ objectAtIndex:indexPath.row];
    _cell.meter.text= [_meter_ objectAtIndex:indexPath.row];
    _cell.meter.textAlignment = NSTextAlignmentRight;
    _cell.categoryname.text = [_category_ objectAtIndex:indexPath.row];
    // イベントを付ける
    [_cell.selectBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
     // Configure the cell...
    return _cell;
}

#pragma mark - handleTouchEvent
- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postRestName = [_restname_ objectAtIndex:indexPath.row];
    _headerLocality = [_restaddress_ objectAtIndex:indexPath.row];
    NSLog(@"postRestName:%@",_postRestName);
    //ViewControllerからViewControllerへ関連付けたSegueにはIdentifierが設定できます。
    //このSegueに付けたIdentifierから遷移を呼び出すことができます。
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        //ここでパラメータを渡す
        RestaurantTableViewController *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestName;
        restVC.headerLocality = _headerLocality;
        
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
