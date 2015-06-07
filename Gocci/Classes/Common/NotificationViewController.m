//
//  NotificationViewController.m
//  Gocci
//
//  Created by kim on 2015/05/16.
//  Copyright (c) 2015年 Kimura. All rights reserved.
//

#import "NotificationViewController.h"
#import "CustomTableViewCell.h"
#import "SVProgressHUD.h"
#import "APIClient.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "Notice.h"

@interface NotificationViewController ()<CustomTableViewCellDelegate>


@property (nonatomic, retain) NSMutableArray *picture_;
@property (nonatomic, retain) NSMutableArray *noticed_;
@property (nonatomic, retain) NSMutableArray *notice_;
@property (nonatomic, copy) NSArray *notices;

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
    
    [self _fetchNotice];

}

- (void)viewWillAppear:(BOOL)animated {
    //JSONをパース
    /*
    NSString *timelineString = [NSString stringWithFormat:@"http://api-gocci.jp/notice"];
    NSString* escaped = [timelineString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* Url = [NSURL URLWithString:escaped];
    NSString *response = [NSString stringWithContentsOfURL:Url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"response:%@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSLog(@"jsonData:%@",jsonData);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"jsonDic:%@",jsonDic);
    
    // ユーザー名
    NSArray *notice = [jsonDic valueForKey:@"notice"];
    _notice_ = [notice mutableCopy];
    // プロフ画像
    NSArray *noticed = [jsonDic valueForKey:@"noticed"];
    _noticed_ = [noticed mutableCopy];
    // ホームページ
    NSArray *picture = [jsonDic valueForKey:@"picture"];
    _picture_ = [picture mutableCopy];
    */
    
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
     return [self.notices count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    /*
    NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.userIcon setImageWithURL:[NSURL URLWithString:dottext]
                       placeholderImage:[UIImage imageNamed:@"default.png"]];
    cell.noticedAt.text = [_noticed_ objectAtIndex:indexPath.row];
    cell.notificationMessage.text = [_notice_ objectAtIndex:indexPath.row];
    */
    // セルにデータを反映
    Notice *post = self.notices[indexPath.row];
    [cell configureWithNotice:post];
    cell.delegate = self;
    
     [SVProgressHUD dismiss];
    
    //TODO:ここでアイコン画像、テキスト、時間をセットしてください。
    //CustomTableView のプロパティとして各項目を設定済みです。
    
    return  cell;
}


- (void)_fetchNotice
{
    [SVProgressHUD show];
    
    
    
    __weak typeof(self)weakSelf = self;
    
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [APIClient notice_WithHandler:^(id result, NSUInteger code, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if (!result || error) {
                // TODO: エラーメッセージを掲出
                return;
            }
            
            [weakSelf _reloadNotice:result];
            [weakSelf.tableView reloadData];
            
        }];
    
}

- (void)_reloadNotice:(NSArray *)result
{
    NSMutableArray *tempNotices = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in (NSArray *)result) {
        [tempNotices addObject:[Notice noticeWithDictionary:dict]];
    }
    
    self.notices = [NSArray arrayWithArray:tempNotices];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}



@end
