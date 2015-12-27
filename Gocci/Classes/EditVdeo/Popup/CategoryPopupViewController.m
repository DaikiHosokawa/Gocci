//
//  CategoryPopupViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/21.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "CategoryPopupViewController.h"
#import "STPopup.h"
#import "Swift.h"

@interface CategoryPopupViewController ()

@end

@implementation CategoryPopupViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"カテゴリー";
        self.contentSizeInPopup = CGSizeMake(300, 355);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Identifier"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"和風";
    }else if(indexPath.row == 1) {
        cell.textLabel.text = @"洋風";
    }else if(indexPath.row == 2) {
        cell.textLabel.text = @"中華";
    }else if(indexPath.row == 3) {
        cell.textLabel.text = @"カレー";
    }else if(indexPath.row == 4) {
        cell.textLabel.text = @"ラーメン";
    }else if(indexPath.row == 5) {
        cell.textLabel.text = @"多国籍";
    }else if(indexPath.row == 6){
        cell.textLabel.text = @"カフェ";
    }else if(indexPath.row == 7){
        cell.textLabel.text = @"居酒屋";
    }
    
    return cell;
}


//1: I want to call method in AllTimelineTableViewController's method from this
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
       VideoPostPreparation.postData.category_string = @"和風";
       VideoPostPreparation.postData.category_id = @"2";
    }else if(indexPath.row == 1) {
        VideoPostPreparation.postData.category_string = @"洋風";
        VideoPostPreparation.postData.category_id = @"3";
    }else if(indexPath.row == 2) {
        VideoPostPreparation.postData.category_string = @"中華";
        VideoPostPreparation.postData.category_id = @"4";
    }else if(indexPath.row == 3) {
        VideoPostPreparation.postData.category_string = @"カレー";
        VideoPostPreparation.postData.category_id = @"5";
    }else if(indexPath.row == 4) {
        VideoPostPreparation.postData.category_string = @"ラーメン";
        VideoPostPreparation.postData.category_id = @"6";
    }else if(indexPath.row == 5){
        VideoPostPreparation.postData.category_string = @"多国籍";
        VideoPostPreparation.postData.category_id = @"7";
    }else if(indexPath.row == 6){
        VideoPostPreparation.postData.category_string = @"カフェ";
        VideoPostPreparation.postData.category_id = @"8";
    }else if(indexPath.row == 7){
        VideoPostPreparation.postData.category_string = @"居酒屋";
        VideoPostPreparation.postData.category_id = @"9";
    }
    [self.popupController dismiss];
}

@end
