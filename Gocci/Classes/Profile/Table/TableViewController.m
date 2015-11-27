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

@interface TableViewController ()<TableViewCellDelegate,UIActionSheetDelegate>


@end

static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const reuseIdentifier = @"Cell";

@implementation TableViewController
{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
    NSMutableArray *timelabel;
    NSMutableDictionary *optionDic;
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
    if ([_receiveDic count] == 0) {
        UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        CGSize boundsSize = self.soda.size;
        iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
        [self.view addSubview:iv];
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
    
    // セルにデータを反映
    TimelinePost *post = self.receiveDic[indexPath.row];
    [cell configureWithTimelinePost:post indexPath:indexPath.row];
    cell.delegate = self;
    
    return cell;
}

-(void)table:(CollectionViewCell *)cell didTapRestname:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
    UsersViewController *vc = (UsersViewController*)self.delegate;
    [self.delegate table:self rest_id:rest_id];
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:rest_id];
}

-(void)table:(CollectionViewCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id{
    
    UIActionSheet *actionsheet = nil;
    
    optionDic = [NSMutableDictionary dictionary];
    [optionDic setObject:post_id forKey:@"POSTID"];
    [optionDic setObject:rest_id forKey:@"RESTID"];
    
    actionsheet = [[UIActionSheet alloc] initWithTitle:@"アクション"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"レストランページへ移動",@"この投稿を削除" ,nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.view];
    
}

-(void)table:(CollectionViewCell *)cell didTapThumb:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postid_[indexPath.row]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"%s sheet = %ld",__func__, (long)buttonIndex);
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"cancel");
    }
    else {
        NSString *r_id = [optionDic objectForKey:@"RESTID"];
        NSString *p_id = [optionDic objectForKey:@"POSTID"];
        
        UsersViewController *vc = ( UsersViewController*)self.delegate;
        
        
        switch (buttonIndex) {
            case 0:
                [self.delegate table:self rest_id:r_id];
                [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:r_id];
                break;
                
            case 1:
                NSLog(@"Problem");
                
                Class class = NSClassFromString(@"UIAlertController");
                if(class)
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を違反報告しますか？" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [APIClient postDelete:p_id handler:^(id result, NSUInteger code, NSError *error) {
                            if (result) {
                                NSLog(@"result:%@",result);
                            }
                        }
                         ];
                        
                        
                    }]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        
                    }]];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else
                {
                    [APIClient postDelete:p_id handler:^(id result, NSUInteger code, NSError *error) {
                        if (result) {
                            NSLog(@"result:%@",result);
                        }
                    }
                     ];
                }
                
                break;
            default:
                break;
        }
        
    }
}



@end
