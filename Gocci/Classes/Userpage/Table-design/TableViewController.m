//
//  TableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import "TableViewController_2.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "CollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "MypageViewController.h"
#import "TableViewCell_2.h"
#import "TimelinePost.h"
#import "SGActionView.h"
#import "Swift.h"


@interface TableViewController_2 ()<TableViewCell_2Delegate,UIActionSheetDelegate>


@end

static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const reuseIdentifier = @"Cell";

@implementation TableViewController_2
{
    NSMutableArray *postid_;
    NSMutableDictionary *optionDic;
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
        UIImage *img = [UIImage imageNamed:@"sad_post.png"];
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        CGRect rect = [UIScreen mainScreen].bounds;
        if (rect.size.height == 568) {
            CGRect original = iv.frame;
            CGRect new = CGRectMake(original.origin.x,
                                    original.origin.y,
                                    original.size.width/1.2,
                                    original.size.height /1.2);
            iv.frame = new;
        }
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
    
    TableViewCell_2 *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // セルにデータを反映
    TimelinePost *post = self.receiveDic[indexPath.row];
    [cell configureWithTimelinePost:post indexPath:indexPath.row];
    cell.delegate = self;
    
    return cell;
}

-(void)table:(CollectionViewCell *)cell didTapRestname:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
    MypageViewController *vc = (MypageViewController*)self.delegate;
    [self.delegate table:self rest_id:rest_id];
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:rest_id];
}

-(void)table:(CollectionViewCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id{
    
    optionDic = [NSMutableDictionary dictionary];
    [optionDic setObject:post_id forKey:@"POSTID"];
    [optionDic setObject:rest_id forKey:@"RESTID"];
    
    MypageViewController *vc = ( MypageViewController*)self.delegate;
    
    
    [SGActionView showGridMenuWithTitle:@"アクション"
                             itemTitles:@[ @"店舗", @"削除",@"保存" ]
                                 images:@[
                                          [UIImage imageNamed:@"restaurant"],
                                          [UIImage imageNamed:@"trash"],
                                          [UIImage imageNamed:@"save"]
                                          ]
                         selectedHandle:^(NSInteger index){
                             
                             NSString *r_id = [optionDic objectForKey:@"RESTID"];
                             NSString *p_id = [optionDic objectForKey:@"POSTID"];
                             
                             
                             if(index == 1){
                                 NSLog(@"Rest");
                                 [self.delegate table:self rest_id:r_id];
                                 [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:r_id];
                             }
                             else if(index == 2){
                                 NSLog(@"Problem");
                                 
                                 Class class = NSClassFromString(@"UIAlertController");
                                 if(class)
                                 {
                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を違反報告しますか？" preferredStyle:UIAlertControllerStyleAlert];
                                     
                                     [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                         [APIClient postBlock:p_id handler:^(id result, NSUInteger code, NSError *error) {
                                             LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
                                             if (result) {
                                                 NSString *alertMessage = @"違反報告をしました";
                                                 UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                 [alrt show];
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
                                     [APIClient postBlock:p_id handler:^(id result, NSUInteger code, NSError *error) {
                                         LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
                                         if (result) {
                                             NSString *alertMessage = @"違反報告をしました";
                                             UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                             [alrt show];
                                         }
                                     }
                                      ];
                                 }                             }
                             else if(index == 3){
                                 NSLog(@"save");
                                 [Export exportVideoToCameraRollForPostID:p_id];
                             }
                         }];

}


-(void)table:(CollectionViewCell *)cell didTapThumb:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
}


-(void)table:(TableViewCell_2 *)cell didTapLikeButton:(NSString *)postID{
    [APIClient postGood:postID handler:^(id result, NSUInteger code, NSError *error) {
        if (result) {
            NSLog(@"result:%@",result);
        }
    }
     ];
}



@end
