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
#import "everyTableViewController.h"
#import "UserpageViewController.h"


static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";

@interface NotificationViewController ()<CustomTableViewCellDelegate>{
    NSMutableArray *notice_category;
    NSMutableArray *post_id;
    NSMutableArray *user_id;
}

@property (nonatomic, retain) NSMutableArray *picture_;
@property (nonatomic, retain) NSMutableArray *noticed_;
@property (nonatomic, retain) NSMutableArray *notice_;
@property (nonatomic, copy) NSArray *notices;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"TableViewCustomCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    [self _fetchNotice];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notices count];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([notice_category[indexPath.row] isEqualToString:@"like"]||[notice_category[indexPath.row] isEqualToString:@"comment"]){
        [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:post_id[indexPath.row]];
    }
    else if([notice_category[indexPath.row] isEqualToString:@"announce"]){
    }
    else if([notice_category[indexPath.row] isEqualToString:@"follow"]){
        [self.supervc performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:user_id[indexPath.row]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Notice *post = self.notices[indexPath.row];
    [cell configureWithNotice:post];
    cell.delegate = self;
    
    return  cell;
}


- (void)_fetchNotice
{
    [SVProgressHUD show];
    __weak typeof(self)weakSelf = self;
    [APIClient Notice:^(id result, NSUInteger code, NSError *error) {
        if (error) {
            NSLog(@"ERROR: Network communication: %@",error);
            [SVProgressHUD dismiss];
            return;
        }
        if (!result) {
            NSLog(@"ERROR: Network communication: server side failed for unnknown reasons");
            [SVProgressHUD dismiss];
            return;
        }
        
        [weakSelf _reloadNotice:result];
        [weakSelf.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
    
}

- (void)_reloadNotice:(NSArray *)result
{
    // User saw his new messages, remove icon badge
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    NSMutableArray *tempNotices = [NSMutableArray arrayWithCapacity:0];
    notice_category = [NSMutableArray arrayWithCapacity:0];
    post_id = [NSMutableArray arrayWithCapacity:0];
    user_id = [NSMutableArray arrayWithCapacity:0];
    
    NSLog(@"resultatnotice:%@",result);
    
    for (NSDictionary *dict in (NSArray *)result) {
        NSDictionary *categoryGet = [dict objectForKey:@"notice"];
        [notice_category addObject:categoryGet];
        NSDictionary *post_idGet = [dict objectForKey:@"notice_post_id"];
        [post_id addObject:post_idGet];
        NSDictionary *user_idGet = [dict objectForKey:@"notice_a_user_id"];
        [user_id addObject:user_idGet];
        [tempNotices addObject:[Notice noticeWithDictionary:dict]];
    }
    
    self.notices = [NSArray arrayWithArray:tempNotices];
    
    NSLog(@"count:%lu",(unsigned long)[self.notices count]);
    
    if ([self.notices count] == 0){
        UIImage *img = [UIImage imageNamed:@"sad_notice.png"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        CGSize boundsSize = self.view.bounds.size;
        iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
        [self.view addSubview:iv];
        
    }
    
    [self.tableView reloadData];
    NSLog(@"noticeCategory:%@",notice_category);
    NSLog(@"postid:%@",post_id);
     NSLog(@"postid:%@",user_id);
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}



@end
