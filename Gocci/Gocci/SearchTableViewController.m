//
//  SearchTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "SearchTableViewController.h"
#import "CustomAnnotation.h"

@interface SearchTableViewController ()<UISearchBarDelegate,MKMapViewDelegate>

@property (nonatomic, retain) MKMapView *mapView;

@end

@implementation SearchTableViewController

@synthesize mapView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.tintColor = [UIColor blackColor];
    searchBar.placeholder = @"キーワードを入力して下さい";
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.delegate = self;
    searchBar.showsSearchResultsButton = YES;
    searchBar.searchBarStyle = UISearchBarStyleProminent;
    
    // UINavigationBar上に、UISearchBarを追加
    self.navigationItem.titleView = searchBar;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 0, 0);
    [self.view addSubview: searchBar];
    
    // 初期フォーカスを設定
    [searchBar becomeFirstResponder];


     [self mapCreate];
    
    //背景にイメージを追加したい
    UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;

}

//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.6];
}


- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    // UISearchBar からフォーカスを外します。
    [searchBar resignFirstResponder];
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
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}



- (void) mapCreate
{
    /* 本当はここを動的に変更できるようにするといいと思う */
    // 緯度経度
    float now_latitude = 35.7100721; // 経度　※本番はここを変数にするか
    float now_longitude = 139.809471; // 緯度　※本番はここを変数にするか
    // タイトル/サブタイトル
    NSString *title = @"タイトル";
    NSString *subTitle = @"サブタイトル";
    /* 本当はここを動的に変更できるようにするといいと思う */
    
    // 経度緯度設定(変数now_を使用)
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(now_latitude, now_longitude);
    
    // マップ生成
    mapView = [[MKMapView alloc] init];
    mapView.delegate = self;
    
    // ユーザの現在地を表示するように設定
    mapView.showsUserLocation = YES;
    [mapView setCenterCoordinate:locationCoordinate animated:NO];
    
    //CustomAnnotationクラスの初期化
    CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] initWithCoordinates:locationCoordinate newTitle:title newSubTitle:subTitle];
    
    // annotationをマップに追加
    [mapView addAnnotation:customAnnotation];
    
    // マップを表示
    [self.view addSubview:self.mapView];

    // 円形オーバーレイ
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(35.703056, 139.58);
    MKCircle *circleOverlay = [MKCircle circleWithCenterCoordinate:location radius:100];
    
    [mapView addOverlays:[NSArray arrayWithObjects: circleOverlay, nil]];
}



- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    // 再利用可能なannotationがあるかどうかを判断するための識別子を定義
    NSString *identifier = @"Pin";
    
    // "Pin"という識別子のついたannotationを使いまわせるかチェック
    annotationView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    // 使い回しができるannotationがない場合、annotationの初期化
    if(annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    
    //ボタンの種類を指定(ここがないとタッチできない)
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = detailButton;
    
    return annotationView;
}


@end
