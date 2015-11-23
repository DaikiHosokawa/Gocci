//
//  TableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "CollectionViewCell.h"
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
    CGSize *changeViewSize;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage *selectedImage  = [[UIImage imageNamed:@"selected_image"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *normalImage    = [[UIImage imageNamed:@"normal_image"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = selectedImage;
        self.tabBarItem.image = normalImage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setFrame:self.view.bounds];
    self.tableView.bounces = YES;
    [self setupData];
}

- (void)viewWillAppear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setupData
{
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
                UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
                UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                CGSize boundsSize = self.soda.size;
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
    [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postid_[indexPath.row]];
}


@end
