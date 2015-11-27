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
#import "UsersViewController.h"

static NSString * const reuseIdentifier = @"Cell";

@interface CollectionViewController ()<UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UIActionSheetDelegate,CollectionViewCellDelegate>

@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";

@implementation CollectionViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
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
            UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
            UIImageView *iv = [[UIImageView alloc] initWithImage:img];
            CGSize boundsSize = self.soda.size;
            iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
            [self.view addSubview:iv];
        }else{
            [self.collectionView reloadData];
        }
}

-(void)collection:(CollectionViewCell *)cell didTapRestname:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
    UsersViewController *vc = (UsersViewController*)self.delegate;
    [self.delegate collection:self rest_id:rest_id];
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:rest_id];
}

-(void)collection:(CollectionViewCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id{
    
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
                [self.delegate collection:self rest_id:r_id];
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

#pragma mark - UICollectionViewDelegate



@end
