//
//  RestPopupViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/21.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "RestPopupViewController.h"
#import "STPopup.h"
#import "RestAddPopupViewController.h"
#import "LocationClient.h"
#import "APIClient.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "Swift.h"

@interface RestPopupViewController ()<CLLocationManagerDelegate>
{
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
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Identifier"];
    [self _getRestaurant:YES];
        

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [restaurant count]+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    
    if (indexPath.row < 30) {
        NSString *restname = restaurant[indexPath.row];
        cell.textLabel.text = restname;
    }
    
    else {
        cell.textLabel.text = @"お店がない時は...";
    }
    return  cell;

}


//1: I want to call method in AllTimelineTableViewController's method from this
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 30) {
        
        NSString *restname = restaurant[indexPath.row];
        NSString *restid = rest_id[indexPath.row];
        
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        
        [userInfo setObject:restname forKey:@"restname"];
        [userInfo setObject:restid forKey:@"restid"];
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"RestnameVCPopped" object:self userInfo:userInfo];
        
        [self.popupController popViewControllerAnimated:YES];
    }
    
    else{
        [self.popupController pushViewController:[RestAddPopupViewController new] animated:YES];
        
    }
    
    
}


/*
 **
 *  初回のレストラン一覧を取得
 *
 *  @param coordinate 検索する緯度・軽度
 */
- (void)_getRestaurant:(BOOL)usingLocationCache{
    
    [SVProgressHUD show];
    
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        [APIClient Near:coordinate.latitude longitude:coordinate.longitude handler:^(id result, NSUInteger code, NSError *error)
         {
             if (error || ![result isKindOfClass:[NSArray class]]) {
                 [SVProgressHUD dismiss];
                 [self.popupController pushViewController:[RestAddPopupViewController new] animated:YES];
                 return;
             }
             
             
             restaurant = [NSMutableArray arrayWithCapacity:30];
             rest_id = [NSMutableArray arrayWithCapacity:30];
             
             for (NSDictionary *dict in (NSArray *)result) {
                 NSDictionary *restnameGet = [dict objectForKey:@"restname"];
                 [restaurant addObject:restnameGet];
                 NSDictionary *restidGet = [dict objectForKey:@"rest_id"];
                 [rest_id addObject:restidGet];
             }
             [self.tableView reloadData];
             [SVProgressHUD dismiss];
             
         }];
        
        
    };
    
    
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         NSLog(@"ここ通ったよ3");
         LOG(@"location=%@, error=%@", location, error);
         
         if (error) {
             // 位置情報の取得に失敗
             // TODO: アラート等を掲出
             [SVProgressHUD dismiss];
             return;
         }
         fetchAPI(location.coordinate);
         
     }];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 121 && buttonIndex == 0)
    {
        //code for opening settings app in iOS 8
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


@end
