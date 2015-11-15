//
//  CategoryPopupViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/21.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "CategoryPopupViewController.h"
#import "STPopup.h"
#import "AppDelegate.h"

@interface CategoryPopupViewController ()

@end

@implementation CategoryPopupViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"カテゴリー";
        self.contentSizeInPopup = CGSizeMake(300, 265);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Identifier"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"和食";
    }else if(indexPath.row == 1) {
        cell.textLabel.text = @"洋食";
    }else if(indexPath.row == 2) {
        cell.textLabel.text = @"中華";
    }else if(indexPath.row == 3) {
        cell.textLabel.text = @"カレー";
    }else if(indexPath.row == 4) {
        cell.textLabel.text = @"ラーメン";
    }else if(indexPath.row == 5){
        cell.textLabel.text = @"カフェ";
    }else if(indexPath.row == 6){
        cell.textLabel.text = @"居酒屋";
    }
    
    return cell;
}


//1: I want to call method in AllTimelineTableViewController's method from this
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    if (indexPath.row == 0) {
       delegate.stringCategory = @"和食";
       delegate.indexCategory = @"2";
        [self.popupController dismiss];
    }else if(indexPath.row == 1) {
        delegate.stringCategory = @"洋食";
        delegate.indexCategory = @"3";
        [self.popupController dismiss];
    }else if(indexPath.row == 2) {
        delegate.stringCategory = @"中華";
        delegate.indexCategory = @"4";
        [self.popupController dismiss];
    }else if(indexPath.row == 3) {
        delegate.stringCategory = @"カレー";
        delegate.indexCategory = @"5";
        [self.popupController dismiss];
    }else if(indexPath.row == 4) {
        delegate.stringCategory = @"ラーメン";
        delegate.indexCategory = @"6";
        [self.popupController dismiss];
    }else if(indexPath.row == 5){
        delegate.stringCategory = @"カフェ";
        delegate.indexCategory = @"8";
        [self.popupController dismiss];
    }else if(indexPath.row == 6){
        delegate.stringCategory = @"居酒屋";
        delegate.indexCategory = @"9";
        [self.popupController dismiss];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
