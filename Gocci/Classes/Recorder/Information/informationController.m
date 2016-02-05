//
//  SortViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/13.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import "informationController.h"
#import "STPopup.h"
#import "ValuePopupViewController.h"
#import "RestPopupViewController.h"
#import "RestAddPopupViewController.h"
#import "CategoryPopupViewController.h"
#import "requestGPSPopupViewController.h"
#import "Swift.h"

@interface informationController ()<CLLocationManagerDelegate>
{
}

@end

@implementation informationController
@synthesize restname = _restname;
@synthesize restid = _restid;
@synthesize category = _category;
@synthesize value = _value;
@synthesize category_flag = _category_flag;
@synthesize lat = _lat;
@synthesize lon = _lon;

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"詳細入力";
        self.contentSizeInPopup = CGSizeMake(300, 135);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 140);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Identifier"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvData:)
                                                 name:@"CategoryVCPopped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvData2:)
                                                 name:@"ValueVCPopped"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvData3:)
                                                 name:@"RestnameVCPopped"
                                               object:nil];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recvData4:)
                                                 name:@"RestAddVCPopped"
                                               object:nil];
     */
    
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(OKBtnDidTap)];

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"閉じる" style:UIBarButtonItemStylePlain target:self action:@selector(DismissDidTap)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    
   
    
    if (indexPath.row == 0) {
     
        
        cell.textLabel.text = @"店名";
        if (self.restname) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"店名：",self.restname];;
        }else{
            if (VideoPostPreparation.postData.rest_name != nil && [VideoPostPreparation.postData.rest_name length] > 0) {
                self.restname = VideoPostPreparation.postData.rest_name;
                self.restid = VideoPostPreparation.postData.rest_id;
                cell.textLabel.text =[NSString stringWithFormat:@"%@%@",@"店名：",self.restname];
            }
        }
        
    }else if (indexPath.row == 1){
        
        cell.textLabel.text = @"カテゴリー";
        if (self.category) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"店名：",self.category];;
        }else{
            if (VideoPostPreparation.postData.category_string != nil && [VideoPostPreparation.postData.category_string length] > 0) {
             
                self.category= VideoPostPreparation.postData.category_string;
                self.category_flag= VideoPostPreparation.postData.category_id;
                 NSLog(@"カテゴリーはあるのか2:%@",self.category);
                cell.textLabel.text =[NSString stringWithFormat:@"%@%@",@"カテゴリー：",self.category];
            }
        }
        
    }else if (indexPath.row == 2){
    
        cell.textLabel.text = @"価格";
        if (self.value) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"価格：",self.value];;
        }else{
            if (VideoPostPreparation.postData.value != nil && [VideoPostPreparation.postData.value length] > 0) {
                self.value= VideoPostPreparation.postData.value;
                cell.textLabel.text =[NSString stringWithFormat:@"%@%@",@"価格：",self.value];
            }
        }
    }
    return cell;
}

- (void) recvData:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString * data = [userInfo objectForKey:@"category"];
    NSString * data2 = [userInfo objectForKey:@"category_flag"];
    NSLog (@"カテゴリー:%@,%@", data,data2);
    self.category = data;
    self.category_flag = data2;
    [self.tableView reloadData];
}

- (void) recvData2:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString * data = [userInfo objectForKey:@"value"];
    NSLog (@"価格:%@", data);
    self.value = data;
    [self.tableView reloadData];
}

- (void) recvData3:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString * data = [userInfo objectForKey:@"restname"];
    NSString * data2 = [userInfo objectForKey:@"restid"];
    NSLog (@"店名:%@", data);
    self.restname = data;
    self.restid = data2;
    VideoPostPreparation.postData.prepared_restaurant = NO;
    [self.tableView reloadData];
}

/*
- (void) recvData4:(NSNotification *) notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString * data = [userInfo objectForKey:@"restname"];
    NSString * data2 = [userInfo objectForKey:@"restid"];
    NSString * data3 = [userInfo objectForKey:@"lat"];
    NSString * data4 = [userInfo objectForKey:@"lon"];
    NSLog (@"店名:%@", data);
    self.restname = data;
    self.restid = data2;
    self.lat = data3;
    self.lon = data4;
    VideoPostPreparation.postData.prepared_restaurant = YES;
    VideoPostPreparation.postData.lat = data3.doubleValue;
    VideoPostPreparation.postData.lon = data4.doubleValue;
    [self.tableView reloadData];
}
 */

- (void)OKBtnDidTap
{
    if (self.restname && self.restid  != nil && self.restname && self.restid > 0) {
        NSLog(@"self.restname%@,self.restid:%@",self.restname,self.restid);
        VideoPostPreparation.postData.rest_name = self.restname;
        VideoPostPreparation.postData.rest_id = self.restid;
    }
    
    if (self.category && self.category_flag  != nil && self.category && self.category_flag > 0) {
        VideoPostPreparation.postData.category_string = self.category;
        VideoPostPreparation.postData.category_id = self.category_flag;
    }
    
    if (self.value  != nil && self.value > 0) {
        VideoPostPreparation.postData.value = self.value;
    }
    
    NSLog(@"restnameは2:%@",VideoPostPreparation.postData.rest_name);
    
    [self.popupController dismiss];
}

- (void)DismissDidTap
{
    if (VideoPostPreparation.postData.rest_name && VideoPostPreparation.postData.rest_id  != nil && VideoPostPreparation.postData.rest_name && VideoPostPreparation.postData.rest_id > 0) {
        NSLog(@"self.restname%@,self.restid:%@",self.restname,self.restid);
       VideoPostPreparation.postData.rest_name = self.restname;
       VideoPostPreparation.postData.rest_id = self.restid;
    }
    
    if (self.category && self.category_flag  != nil && self.category && self.category_flag > 0) {
       // VideoPostPreparation.postData.category_string = self.category;
       // VideoPostPreparation.postData.category_id = self.category_flag;
    }
    
    if (self.value  != nil && self.value > 0) {
       // VideoPostPreparation.postData.value = self.value;
    }
    
    NSLog(@"restnameは2:%@",VideoPostPreparation.postData.rest_name);
    
    [self.popupController dismiss];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)
        {
            [self.popupController pushViewController:[requestGPSPopupViewController new] animated:YES];
        }
        else if ([Network offline]) {
            [self.popupController pushViewController:[RestAddPopupViewController new] animated:YES];
        }
        else {
            [self.popupController pushViewController:[RestPopupViewController new] animated:YES];
        }

    }
    else if(indexPath.row == 1){
        [self.popupController pushViewController:[CategoryPopupViewController new] animated:YES];
    }
    else if(indexPath.row == 2){
        [self.popupController pushViewController:[ValuePopupViewController new] animated:YES];
    }
}



@end
