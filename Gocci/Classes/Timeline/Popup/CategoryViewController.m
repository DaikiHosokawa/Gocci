//
//  CategoryViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/13.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "CategoryViewController.h"
#import "STPopup.h"
#import "SortViewController.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"カテゴリー";
        self.contentSizeInPopup = CGSizeMake(300, 400);
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
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"選択なし";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"和風";
    }else if(indexPath.row == 2) {
        cell.textLabel.text = @"洋風";
    }else if(indexPath.row == 3) {
        cell.textLabel.text = @"中華";
    }else if(indexPath.row == 4) {
        cell.textLabel.text = @"カレー";
    }else if(indexPath.row == 5) {
        cell.textLabel.text = @"ラーメン";
    }else if(indexPath.row == 6){
        cell.textLabel.text = @"多国籍";
    }else if(indexPath.row == 7){
        cell.textLabel.text = @"カフェ";
    }else if(indexPath.row == 8){
        cell.textLabel.text = @"居酒屋";
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    if (indexPath.row == 0) {
        [userInfo setObject:@"未選択" forKey:@"category"];
        [userInfo setObject:@"" forKey:@"category_flag"];
    }
    else if (indexPath.row == 1) {
        [userInfo setObject:@"和風" forKey:@"category"];
        [userInfo setObject:@"2" forKey:@"category_flag"];
    }else if(indexPath.row == 2) {
        [userInfo setObject:@"洋風" forKey:@"category"];
        [userInfo setObject:@"3" forKey:@"category_flag"];
    }else if(indexPath.row == 3) {
        [userInfo setObject:@"中華" forKey:@"category"];
        [userInfo setObject:@"4" forKey:@"category_flag"];
    }else if(indexPath.row == 4) {
        [userInfo setObject:@"カレー" forKey:@"category"];
        [userInfo setObject:@"5" forKey:@"category_flag"];
    }else if(indexPath.row == 5) {
        [userInfo setObject:@"ラーメン" forKey:@"category"];
        [userInfo setObject:@"6" forKey:@"category_flag"];
    }else if(indexPath.row == 6) {
        [userInfo setObject:@"中華" forKey:@"category"];
        [userInfo setObject:@"7" forKey:@"category_flag"];
    }else if(indexPath.row == 7) {
        [userInfo setObject:@"カフェ" forKey:@"category"];
        [userInfo setObject:@"8" forKey:@"category_flag"];
    }else if(indexPath.row == 8) {
        [userInfo setObject:@"居酒屋" forKey:@"category"];
        [userInfo setObject:@"9" forKey:@"category_flag"];
    }
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"CategoryVCPopped" object:self userInfo:userInfo];
    [self.popupController popViewControllerAnimated:YES];
}


@end
