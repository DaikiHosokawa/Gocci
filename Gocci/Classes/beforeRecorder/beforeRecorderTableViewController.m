//
//  beforeRecorderTableViewController.m
//  Gocci
//
//  Created by デザミ on 2015/02/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "beforeRecorderTableViewController.h"
#import "AppDelegate.h"
#import "SCRecorderViewController.h"
#import "APIClient.h"
#import "beforeCell.h"
#import "Restaurant.h"
#import "LocationClient.h"

static NSString * const SEGUE_GO_SC_RECORDER = @"goSCRecorder";

@import CoreLocation;

@interface beforeRecorderTableViewController ()<beforeCellDelegate>
{
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
}

- (void)showDefaultContentView;

@property (nonatomic, strong) NSMutableArray *restname_;
@property (nonatomic, strong) NSMutableArray *category_;
@property (nonatomic, strong) NSMutableArray *meter_;
@property (nonatomic, strong) NSMutableArray *jsonlat_;
@property (nonatomic, strong) NSMutableArray *jsonlon_;
@property (nonatomic, strong) NSMutableArray *restaddress_;
@property (nonatomic, strong) NSString *nowlat_;
@property (nonatomic, strong) NSString *nowlon_;
@property (nonatomic, copy) NSArray *restaurants;

@end

@implementation beforeRecorderTableViewController

#pragma mark - アイテム名登録用
/*
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
         UIImage *image = [[UIImage imageNamed:@"tabbaritem_posting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.image = image;
        UIImage *image_sel = [[UIImage imageNamed:@"tabbaritem_posting_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = image_sel;
	}
	return self;
}
 */

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    AppDelegate *appDelegete = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
    {
        // 画面を表示した初回の一回のみ、現在地を中心にしたレストラン一覧を取得する
        static dispatch_once_t searchCurrentLocationOnceToken;
        dispatch_once(&searchCurrentLocationOnceToken, ^{
            [self _fetchFirstRestaurantsWithCoordinate:location.coordinate];
        });
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
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"beforeCell" bundle:nil]
         forCellReuseIdentifier:beforeCellIdentifier];

  
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
        [self showDefaultContentView];
    }


}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
////#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 1;
//}

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
    return [beforeCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    beforeCell *cell = (beforeCell *)[tableView dequeueReusableCellWithIdentifier:beforeCellIdentifier];
    if (!cell) {
        cell = [beforeCell cell];
    }
    
    Restaurant *restaurant = self.restaurants[indexPath.row];
    [cell configureWithRestaurant:restaurant index:indexPath.row];
    cell.delegate = self;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"%s",__func__);
    
    NSString *postRestName = [_restname_ objectAtIndex:indexPath.row];
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.gText = postRestName;

	//遷移：SCRecorderVideoController
	//[self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER sender:self];

	// 選択状態の解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    delegate.gText = restaurant.restname;
    [self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER
                               sender:@{
                                       @"rest_name": restaurant.restname,
                                       }];
}

- (void)beforeCell:(beforeCell *)cell shouldDetailAtIndex2:(NSUInteger)index
{
    Restaurant *restaurant = self.restaurants[index];
    // グローバル変数に保存
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.gText = restaurant.restname;
    [self performSegueWithIdentifier:SEGUE_GO_SC_RECORDER
                              sender:@{
                                       @"rest_name": restaurant.restname,
                                       }];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	//2つ目の画面にパラメータを渡して遷移する
	// !!!:dezamisystem
	if ([segue.identifier isEqualToString:SEGUE_GO_SC_RECORDER])
	{
		//ここでパラメータを渡す
		SCRecorderViewController *recVC = segue.destinationViewController;
		//recVC.postID = (NSString *)sender;
		recVC.hidesBottomBarWhenPushed = YES;	// タブバー非表示
	}
}


/**
 *  初回のレストラン一覧を取得
 *
 *  @param coordinate 検索する緯度・軽度
 */
- (void)_fetchFirstRestaurantsWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    [APIClient distWithLatitude:coordinate.latitude
                      longitude:coordinate.longitude
                          limit:30
                        handler:^(id result, NSUInteger code, NSError *error)
     {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         
         if (!result || error) {
             // TODO: エラーメッセージを掲出
             return;
         }
         
         [weakSelf _reloadRestaurants:result];
         if ([self.restaurants count]== 0) {
             NSLog(@"投稿がない");
             _emptyView.hidden = NO;
         }
     } useCache:^(id cachedResult)
     {
         if (!cachedResult) {
             return;
         }
         
         [weakSelf _reloadRestaurants:cachedResult];
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


#pragma mark -
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
        descriptionLabel.text = @"投稿したい店を選びましょう！";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}


@end
