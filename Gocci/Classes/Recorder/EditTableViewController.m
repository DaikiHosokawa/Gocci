//
//  SortViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/13.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import "EditTableViewController.h"
#import "STPopup.h"
#import "ValuePopupViewController.h"
#import "RestPopupViewController.h"
#import "CategoryPopupViewController.h"
#import "requestGPSPopupViewController.h"

@interface EditTableViewController ()<CLLocationManagerDelegate>

@end

@implementation EditTableViewController

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
    }else if (indexPath.row == 1){
        cell.textLabel.text = @"カテゴリー";
    }else if (indexPath.row == 2){
        cell.textLabel.text = @"価格";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            RestPopupViewController* rvc = [RestPopupViewController new];
            [self.popupController pushViewController:rvc animated:YES];
        }
        else {
            switch ([CLLocationManager authorizationStatus]) {
                    
                case kCLAuthorizationStatusNotDetermined:
                case kCLAuthorizationStatusAuthorizedAlways:
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                case kCLAuthorizationStatusDenied:
                case kCLAuthorizationStatusRestricted:
                    NSLog(@"not permitted");
                   requestGPSPopupViewController* rvc = [requestGPSPopupViewController new];
                    [self.popupController pushViewController:rvc animated:YES];
                    
            }
        }

    }else if(indexPath.row == 1){
        CategoryPopupViewController* cvc = [CategoryPopupViewController new];
        [self.popupController pushViewController:cvc animated:YES];
    }else if(indexPath.row == 2){
        ValuePopupViewController* vvc = [ValuePopupViewController new];
        [self.popupController pushViewController:vvc animated:YES];
    }
}



@end
