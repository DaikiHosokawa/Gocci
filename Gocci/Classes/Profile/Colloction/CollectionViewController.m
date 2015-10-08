//
//  CollectionViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "CollectionViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "STCustomCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "UsersViewController.h"
#import "STCustomCollectionViewCell.h"

static NSString * const reuseIdentifier = @"Cell";
static const CGFloat kCellMargin = 5;

@interface CollectionViewController ()<UICollectionViewDelegateFlowLayout>

@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@implementation CollectionViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
}


- (void)viewWillAppear:(BOOL)animated{
    [self setupData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.clearsSelectionOnViewWillAppear = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupData
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [APIClient User:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        
        // 取得したデータを self.posts に格納
        thumb = [NSMutableArray arrayWithCapacity:0];
        postid_ = [NSMutableArray arrayWithCapacity:0];
        restname = [NSMutableArray arrayWithCapacity:0];
        
        NSArray* items = (NSArray*)[result valueForKey:@"posts"];
        
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
        }else{
            [self.collectionView reloadData];
        }

        
    }];
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [postid_ count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    STCustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:thumb[indexPath.row]]
                  placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    cell.title.text = restname[indexPath.row];
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"postid:%@",postid_[indexPath.row]);
    [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postid_[indexPath.row]];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, kCellMargin, kCellMargin, kCellMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    CGFloat length = (CGRectGetWidth(self.view.frame) / 2) - (kCellMargin * 2);
    if (isPad) {
        // fixed size for iPad in landscape and portrait
        length = 256 - (kCellMargin * 2);
    }
    return CGSizeMake(length, length);
}


@end
