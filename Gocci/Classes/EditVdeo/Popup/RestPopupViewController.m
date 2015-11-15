//
//  RestPopupViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/21.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "RestPopupViewController.h"
#import "STPopup.h"
#import "LocationClient.h"
#import "APIClient.h"
#import "AppDelegate.h"

@interface RestPopupViewController (){
    //API
    NSMutableArray *restaurant;
    NSMutableArray *rest_id;
}


@end

@implementation RestPopupViewController


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"店名";
        self.contentSizeInPopup = CGSizeMake(300, 310);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _getRestaurant:YES];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Identifier"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [restaurant count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
     NSString *restname = restaurant[indexPath.row];
    cell.textLabel.text = restname;
       return cell;
}


//1: I want to call method in AllTimelineTableViewController's method from this
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *restname = restaurant[indexPath.row];
    NSString *restid = rest_id[indexPath.row];
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.stringTenmei = restname;
    delegate.indexTenmei = restid;
    [self.popupController dismiss];
    
}


/*
 **
 *  初回のレストラン一覧を取得
 *
 *  @param coordinate 検索する緯度・軽度
 */
- (void)_getRestaurant:(BOOL)usingLocationCache{
    
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        [APIClient Near:coordinate.latitude longitude:coordinate.longitude handler:^(id result, NSUInteger code, NSError *error)
         {
             
             restaurant = [NSMutableArray arrayWithCapacity:0];
             rest_id = [NSMutableArray arrayWithCapacity:0];
             
             for (NSDictionary *dict in (NSArray *)result) {
                 NSDictionary *restnameGet = [dict objectForKey:@"restname"];
                 [restaurant addObject:restnameGet];
                 NSDictionary *restidGet = [dict objectForKey:@"rest_id"];
                 [rest_id addObject:restidGet];
             }
             [self.tableView reloadData];
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }];
        
        
    };
    
    // 位置情報キャッシュを使う場合で、位置情報キャッシュが存在する場合、
    // キャッシュされた位置情報を利用して API からデータを取得する
    CLLocation *cachedLocation = [LocationClient sharedClient].cachedLocation;
    if (usingLocationCache && cachedLocation != nil) {
        fetchAPI(cachedLocation.coordinate);
        NSLog(@"ここ通ったよ2");
        return;
    }
    
    // 位置情報キャッシュを使わない、あるいはキャッシュが存在しない場合、
    // 位置情報を取得してから API へアクセスする
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         NSLog(@"ここ通ったよ3");
         LOG(@"location=%@, error=%@", location, error);
         
         if (error) {
             // 位置情報の取得に失敗
             // TODO: アラート等を掲出
             return;
         }
         fetchAPI(location.coordinate);
         
     }];
    
    
}

@end
