//
//  TableViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "STCustomCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "UsersViewController.h"
#import "TableViewCell.h"
#import "TimelinePost.h"

@interface TableViewController ()


@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const reuseIdentifier = @"Cell";

@implementation TableViewController
{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setupData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupData
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   
            // 取得したデータを self.posts に格納
            thumb = [NSMutableArray arrayWithCapacity:0];
            postid_ = [NSMutableArray arrayWithCapacity:0];
            restname = [NSMutableArray arrayWithCapacity:0];
    
    NSLog(@"ここでは:%@",_receiveDic);
    
            NSArray* items = (NSArray*)_receiveDic;
            
            for (NSDictionary *post in items) {
                
                NSDictionary *thumbGet = [post objectForKey:@"thumbnail"];
                [thumb addObject:thumbGet];
                NSDictionary *postidGet = [post objectForKey:@"post_id"];
                [postid_ addObject:postidGet];
                NSDictionary *restnameGet = [post objectForKey:@"restname"];
                [restname addObject:restnameGet];
            }
            NSLog(@"thumb:%@,id:%@,restname:%@",thumb,postid_,restname);
            
            if ([thumb count] == 0) {
                // 画像表示例文
                UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
                UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                CGSize boundsSize = self.view.bounds.size;
                iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
                [self.view addSubview:iv];
                self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            }else{
            [self.tableView reloadData];
            }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_receiveDic count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"indexPath:%ld",(long)indexPath.row);
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.thumbImageView sd_setImageWithURL:[NSURL URLWithString:thumb[indexPath.row]]
                      placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    NSLog(@"title:%@",cell.titleLabel.text);
    cell.titleLabel.text = restname[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postid_[indexPath.row]];
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
