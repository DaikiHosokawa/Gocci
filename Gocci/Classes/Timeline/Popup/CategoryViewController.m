//
//  CategoryViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/13.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "CategoryViewController.h"
#import "STPopup.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"カテゴリー";
        self.contentSizeInPopup = CGSizeMake(300, 310);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 220);
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
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"選択なし";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"和食";
    }else if(indexPath.row == 2) {
        cell.textLabel.text = @"洋食";
    }else if(indexPath.row == 3) {
        cell.textLabel.text = @"中華";
    }else if(indexPath.row == 4) {
        cell.textLabel.text = @"カレー";
    }else if(indexPath.row == 5) {
        cell.textLabel.text = @"ラーメン";
    }else if(indexPath.row == 6){
        cell.textLabel.text = @"居酒屋";
    }else if(indexPath.row == 7){
        cell.textLabel.text = @"カフェ";
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"1"];
        [self.popupController dismiss];
    }
    else if (indexPath.row == 1) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"2"];
        
        [self.popupController dismiss];
    }else if(indexPath.row == 2) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"3"];
        [self.popupController dismiss];
    }else if(indexPath.row == 3) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"4"];
        [self.popupController dismiss];
    }else if(indexPath.row == 4) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"5"];
        [self.popupController dismiss];
    }else if(indexPath.row == 5) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"6"];
        [self.popupController dismiss];
    }else if(indexPath.row == 6) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"8"];
        [self.popupController dismiss];
    }else if(indexPath.row == 7) {
        [self.timelinePageMenuViewController.currentVisibleSortableSubViewController sortFunc:@"9"];
        [self.popupController dismiss];
    }
}


@end
