//
//  NotificationViewController.m
//  Gocci
//
//  Created by kim on 2015/05/16.
//  Copyright (c) 2015年 Kimura. All rights reserved.
//

#import "NotificationViewController.h"
#import "CustomTableViewCell.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    // TODO: DataSource を定義してください
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"TableViewCustomCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //TODO:現在は1固定にしていますが、API から取得した値の個数をセットするように修正してください
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //TODO:ここでアイコン画像、テキスト、時間をセットしてください。
    //CustomTableView のプロパティとして各項目を設定済みです。
    
    return  cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}


@end
