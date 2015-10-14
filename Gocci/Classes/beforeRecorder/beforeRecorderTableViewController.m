//
//  beforeRecorderTableViewController.m
//  Gocci
//
//  Created by INASE on 2015/02/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "beforeRecorderTableViewController.h"
#import "AppDelegate.h"
#import "SCRecorderViewController.h"
#import "APIClient.h"
#import "beforeCell.h"
#import "SVProgressHUD.h"
#import "Restaurant.h"
#import "LocationClient.h"

#import "Swift.h"

//static NSString * const SEGUE_GO_SC_RECORDER = @"goSCRecorder";

@import CoreLocation;

@interface beforeRecorderTableViewController ()<beforeCellDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
}

@property (nonatomic, strong) NSMutableArray *restname_;
@property (nonatomic, strong) NSMutableArray *category_;
@property (nonatomic, strong) NSMutableArray *meter_;
@property (nonatomic, strong) NSMutableArray *jsonlat_;
@property (nonatomic, strong) NSMutableArray *jsonlon_;
@property (nonatomic, strong) NSMutableArray *restaddress_;
@property (nonatomic, strong) NSString *nowlat_;
@property (nonatomic, strong) NSString *nowlon_;
@property (nonatomic, copy) NSArray *restaurants;
@property (nonatomic, strong) UIRefreshControl *refresh;


@end

@implementation beforeRecorderTableViewController

#pragma mark - アイテム名登録用


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         //        // 画面を表示した初回の一回のみ、現在地を中心にしたレストラン一覧を取得する
         //        static dispatch_once_t searchCurrentLocationOnceToken;
         //        dispatch_once(&searchCurrentLocationOnceToken, ^{
         //            [self _fetchFirstRestaurantsWithCoordinate:location.coordinate];
         //        });
         
         //画面表示のたびに、現在地を中心にしたレストラン一覧を取得する
         [self _fetchFirstRestaurantsWithCoordinate:location.coordinate];
         
     }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Table View の設定
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"beforeCell" bundle:nil]
         forCellReuseIdentifier:beforeCellIdentifier];
    
    
    // Pull to refresh
    self.refresh = [UIRefreshControl new];
    [self.refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refresh];
    
    //ナビゲーションバーに画像
    {
        //タイトル画像設定
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    //	UIImage *image = [[UIImage imageNamed:@"tabbaritem_posting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //	self.tabBarItem.image = image;
    
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
        
    }
    
    
}
#pragma mark - Table view data source


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
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [beforeCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.row <= 30) {
    beforeCell *cell = (beforeCell *)[tableView dequeueReusableCellWithIdentifier:beforeCellIdentifier];
    
    Restaurant *restaurant = self.restaurants[indexPath.row];
    [cell configureWithRestaurant:restaurant index:indexPath.row];
    cell.delegate = self;
    
    if(indexPath.row == 29){
        cell.restaurantNameLabel.text = @"店舗がないときは。。。。";
        // [cell.cont setBackgroundColor:[UIColor orangeColor]];
        //cell.backgroundColor = [UIColor orangeColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
    
    
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"選択したセル：%ld",(long)indexPath.row);
    
    if(indexPath.row <= 28){
        
        Restaurant *restaurant = self.restaurants[indexPath.row];
        // グローバル変数に保存
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        delegate.restname = restaurant.restname;
        delegate.rest_id = restaurant.rest_id;
        // モーダル閉じる
        [self dismissWithTenmei];
    }
    
    if(indexPath.row == 29){
        FirstalertView = [[UIAlertView alloc] initWithTitle:@"店名を入力してください"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
        FirstalertView.delegate       = self;
        FirstalertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [FirstalertView show];
        NSLog(@"フラグ：%ld",(long)indexPath.row);
        
    }
    
    // 選択状態の解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(FirstalertView == alertView){
        if( buttonIndex == alertView.cancelButtonIndex ) { return; }
        
        NSString* textValue = [[alertView textFieldAtIndex:0] text];
        if( [textValue length] > 0 )
        {
            [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
             {
                 NSLog(@"入力店名：%@",textValue);
                 
                 [APIClient restInsert:textValue latitude:location.coordinate.latitude longitude:location.coordinate.longitude handler:^(id result, NSUInteger code, NSError *error) {
                     LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
                     
                     if ([result[@"code"] integerValue] == 200) {
                         AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                         delegate.restname = textValue;
                         delegate.rest_id  = result[@"rest_id"];
                         // モーダル閉じる
                         [self dismissWithTenmei];
                     }
                     
                 }];
             }];
            
        }
    }
    
}

#pragma mark 店名転送
-(void)dismissWithTenmei
{
    //SCRecorderViewControllerに送信→SCSecondViewに送信
    // ストーリーボードを取得
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:Util.getInchString bundle:nil];
    //ビューコントローラ取得
    SCRecorderViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"screcorder"];

    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [viewController sendTenmeiString:delegate.restname];
    
    //モーダルを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)beforeCell:(beforeCell *)cell shouldShowMapAtIndex:(NSUInteger)index
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

- (void)beforeCell:(beforeCell *)cell shouldDetailAtIndex:(NSUInteger)index
{
    Restaurant *restaurant = self.restaurants[index];
    // グローバル変数に保存
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.restname = restaurant.restname;
    
    // モーダル閉じる
    [self dismissWithTenmei];
    
    NSLog(@"ここを通ってる1");
    
    //    [self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER
    //                               sender:@{
    //                                       @"rest_name": restaurant.restname,
    //                                       }];
}

- (void)beforeCell:(beforeCell *)cell shouldDetailAtIndex2:(NSUInteger)index
{
    Restaurant *restaurant = self.restaurants[index];
    // グローバル変数に保存
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.restname = restaurant.restname;
    
    // モーダル閉じる
    [self dismissWithTenmei];
    
    NSLog(@"ここを通ってる2");
    
    //    [self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER
    //                              sender:@{
    //                                       @"rest_name": restaurant.restname,
    //                                       }];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //	//2つ目の画面にパラメータを渡して遷移する
    //	// !!!:dezamisystem
    //	if ([segue.identifier isEqualToString:SEGUE_GO_SC_RECORDER])
    //	{
    //		//ここでパラメータを渡す
    //		SCRecorderViewController *recVC = segue.destinationViewController;
    //		//recVC.postID = (NSString *)sender;
    //		recVC.hidesBottomBarWhenPushed = YES;	// タブバー非表示
    //	}
}

- (void)refresh:(UIRefreshControl *)sender
{
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         [self _fetchFirstRestaurantsWithCoordinate:location.coordinate];
     }];
}



/**
 *  初回のレストラン一覧を取得
 *
 *  @param coordinate 検索する緯度・軽度
 */
- (void)_fetchFirstRestaurantsWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    [SVProgressHUD show];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    
    [weakSelf.refresh beginRefreshing];
    
    [APIClient Near:coordinate.latitude longitude:coordinate.longitude handler:^(id result, NSUInteger code, NSError *error)
     {
         
         NSLog(@"before recorder result:%@",result);
         
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         if ([weakSelf.refresh isRefreshing]) {
             [weakSelf.refresh endRefreshing];
         }
         
         if (!result || error) {
             // TODO: エラーメッセージを掲出
             return;
         }
         
         [weakSelf _reloadRestaurants:result];
         if ([self.restaurants count]== 0) {
             NSLog(@"投稿がない");
             _emptyView.hidden = NO;
             [SVProgressHUD dismiss];
         }
     } useCache:^(id cachedResult)
     {
         if (!cachedResult) {
              [SVProgressHUD dismiss];
             return;
         }
         
         [weakSelf _reloadRestaurants:cachedResult];
         
         // 表示の更新
         [weakSelf.tableView reloadData];
          [SVProgressHUD dismiss];
     }];
}


/**
 *  レストラン一覧を更新
 *
 *  @param result API からの取得結果
 */
- (void)_reloadRestaurants:(NSArray *)result
{
    NSMutableArray *tempRestaurants = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in (NSArray *)result) {
        [tempRestaurants addObject:[Restaurant restaurantWithDictionary:dict]];
    }
    
    self.restaurants = [NSArray arrayWithArray:tempRestaurants];
    NSLog(@"restaurant:%@",self.restaurants);
    [self.tableView reloadData];
}

- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate9"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate9"];
    // 保存
    [userDefaults synchronize];
    // 初回起動
    return YES;
}




- (IBAction)onBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
