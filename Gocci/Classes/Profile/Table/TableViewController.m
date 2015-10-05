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

@interface TableViewController ()

@property (nonatomic, retain) TableViewCell *cell;

@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@implementation TableViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *postdate;
    NSMutableArray *restname;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TableViewCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated{
    [self _fetchProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchProfile
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    [APIClient User:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        
        NSLog(@"users result:%@",result);
        
        // 取得したデータを self.posts に格納
        thumb = [NSMutableArray arrayWithCapacity:0];
        postid_ = [NSMutableArray arrayWithCapacity:0];
        postdate = [NSMutableArray arrayWithCapacity:0];
        restname = [NSMutableArray arrayWithCapacity:0];
        
        NSArray* items = (NSArray*)[result valueForKey:@"posts"];
        
        for (NSDictionary *post in items) {
            
            NSDictionary *thumbGet = [post objectForKey:@"thumbnail"];
            [thumb addObject:thumbGet];
            NSDictionary *postidGet = [post objectForKey:@"post_id"];
            [postid_ addObject:postidGet];
            NSDictionary *dateGet = [post objectForKey:@"post_date"];
            [postdate addObject:dateGet];
            NSDictionary *restnameGet = [post objectForKey:@"restname"];
            [restname addObject:restnameGet];
        }
        [self.tableView reloadData];
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return [thumb count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    _cell = (TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    
    NSLog(@"thumb:%@",thumb);
    
    [_cell.thumb sd_setImageWithURL:[NSURL URLWithString:thumb[indexPath.row]]
                  placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    
    _cell.postDate.text = postdate[indexPath.row];
    NSLog(@"text:%@",_cell.postDate.text);
    _cell.restname.text = restname[indexPath.row];
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 238;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"postid:%@",postid_[indexPath.row]);
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
