//
//  CollectionViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "CollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "MypageViewController.h"
#import "SGActionView.h"

static NSString * const reuseIdentifier = @"Cell";

@interface CollectionViewController ()<UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,CollectionViewCellDelegate>

@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";

@implementation CollectionViewController{
    NSMutableDictionary *optionDic;
}


- (void)viewWillAppear:(BOOL)animated{
    
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

- (UIScrollView *)stretchableSubViewInSubViewController:(id)subViewController
{
    return self.collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = self.soda;
    self.clearsSelectionOnViewWillAppear = NO;
    [self.collectionView setBounces:YES];
    [self setupData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupData
{
    
    if ([_receiveDic2 count] == 0) {
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
        [self.collectionView reloadData];
    }
}

-(void)collection:(CollectionViewCell *)cell didTapRestname:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
    MypageViewController *vc = (MypageViewController*)self.delegate;
    [self.delegate collection:self rest_id:rest_id];
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:rest_id];
}

-(void)collection:(CollectionViewCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id{
    
    
    optionDic = [NSMutableDictionary dictionary];
    [optionDic setObject:post_id forKey:@"POSTID"];
    [optionDic setObject:rest_id forKey:@"RESTID"];
    
    MypageViewController *vc = ( MypageViewController*)self.delegate;
    
    
    [SGActionView showGridMenuWithTitle:@"アクション"
                             itemTitles:@[ @"店舗", @"削除",@"保存" ]
                                 images:@[[UIImage imageNamed:@"restaurant"],
                                           [UIImage imageNamed:@"trash"],
                                          [UIImage imageNamed:@"save"]
                                          ]
                         selectedHandle:^(NSInteger index){
                             
                             NSString *r_id = [optionDic objectForKey:@"RESTID"];
                             NSString *p_id = [optionDic objectForKey:@"POSTID"];
                             
                             
                             if(index == 1){
                                 NSLog(@"Rest");
                                 [self.delegate collection:self rest_id:r_id];
                                 [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:r_id];
                             }
                             else if(index == 2){
                                 NSLog(@"削除");
                                 
                                 Class class = NSClassFromString(@"UIAlertController");
                                 if(class)
                                 {
                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を削除しますか？" preferredStyle:UIAlertControllerStyleAlert];
                                     
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
                                 
                             }
                             else if(index == 3){
                                 NSLog(@"save");
                             }
                         }];
    
    
}

-(void)collection:(CollectionViewCell *)cell didTapThumb:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
}

-(void)collection:(CollectionViewCell *)cell didTapLikeButton:(NSString *)postID{
    [APIClient postGood:postID handler:^(id result, NSUInteger code, NSError *error) {
        if (result) {
            NSLog(@"result:%@",result);
        }
    }
     ];
}





- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_receiveDic2 count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    for (UIView *subview in [cell.imageView subviews]) {
        [subview removeFromSuperview];
    }
    
    // セルにデータを反映
    TimelinePost *post = self.receiveDic2[indexPath.row];
    [cell configureWithTimelinePost:post indexPath:indexPath.row];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate



@end
