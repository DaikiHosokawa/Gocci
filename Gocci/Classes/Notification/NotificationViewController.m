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
#import "usersTableViewController_other.h"


static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@interface NotificationViewController ()<CustomTableViewCellDelegate>{
    NSMutableArray *notice_category;
    NSMutableArray *post_id;
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    //Storyboardを特定して
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
    
    if([notice_category[indexPath.row] isEqualToString:@"like"]||[notice_category[indexPath.row] isEqualToString:@"comment"]){
        NSLog(@"コメント画面に遷移");
        NSLog(@"postid:%@",post_id[indexPath.row]);
        [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:post_id[indexPath.row]];
       
        //[self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:post_id[indexPath.row]];
        
        /*
         everyTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"evTable"];
         TimelineTableViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"evTable"];
         [self.navigationController pushViewController:controller animated:YES];
         */
        //everyTableViewControllerに遷移したい
        
        /*
         everyTableViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"evTable"];
         //[self.storyboard instantiateViewControllerWithIdentifier:@"evTable"];
         [self.navigationController pushViewController:controller animated:YES];
         */
    }
    else if([notice_category[indexPath.row] isEqualToString:@"announce"]){
        NSLog(@"今の所、遷移なし");
    }
    else if([notice_category[indexPath.row] isEqualToString:@"follow"]){
        NSLog(@"ユーザー画面遷移");
    }
    /*
     everyTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"evTable"];
     [self.navigationController pushViewController:controller animated:YES];
     */
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // セルにデータを反映
    Notice *post = self.notices[indexPath.row];
    [cell configureWithNotice:post];
    cell.delegate = self;
    
    
    //TODO:ここでアイコン画像、テキスト、時間をセットしてください。
    //CustomTableView のプロパティとして各項目を設定済みです。
    
    return  cell;
}


- (void)_fetchNotice
{
    [SVProgressHUD show];
    
    
    
    __weak typeof(self)weakSelf = self;
    
  //  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [APIClient Notice:^(id result, NSUInteger code, NSError *error) {
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (!result || error) {
            // TODO: エラーメッセージを掲出
            return;
        }
        
        [weakSelf _reloadNotice:result];
        [weakSelf.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
    
}

- (void)_reloadNotice:(NSArray *)result
{
    NSMutableArray *tempNotices = [NSMutableArray arrayWithCapacity:0];
    notice_category = [NSMutableArray arrayWithCapacity:0];
    post_id = [NSMutableArray arrayWithCapacity:0];
    
    NSLog(@"resultatnotice:%@",result);
    
    for (NSDictionary *dict in (NSArray *)result) {
        NSDictionary *categoryGet = [dict objectForKey:@"notice"];
        [notice_category addObject:categoryGet];
        NSDictionary *post_idGet = [dict objectForKey:@"notice_post_id"];
        [post_id addObject:post_idGet];
        [tempNotices addObject:[Notice noticeWithDictionary:dict]];
    }
    
    self.notices = [NSArray arrayWithArray:tempNotices];
    
    NSLog(@"count:%lu",(unsigned long)[self.notices count]);
    
    if ([self.notices count] == 0){
        // 画像表示例文
        UIImage *img = [UIImage imageNamed:@"sad_notice.png"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        CGSize boundsSize = self.view.bounds.size;
        iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
        [self.view addSubview:iv];
        
    }
    
    [self.tableView reloadData];
    NSLog(@"noticeCategory:%@",notice_category);
     NSLog(@"postid:%@",post_id);
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}



@end
