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

@interface CollectionViewController ()

@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@implementation CollectionViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
}


- (void)viewWillAppear:(BOOL)animated{
    [self _fetchProfile];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"STCustomCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"CellId"];
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
        
        NSArray* items = (NSArray*)[result valueForKey:@"posts"];
        
        for (NSDictionary *post in items) {
            
            NSDictionary *thumbGet = [post objectForKey:@"thumbnail"];
            [thumb addObject:thumbGet];
            NSDictionary *postidGet = [post objectForKey:@"post_id"];
            [postid_ addObject:postidGet];
        }
        [self.collectionView reloadData];
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [thumb count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"CellId";
    STCustomCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    [cell.thumb sd_setImageWithURL:[NSURL URLWithString:thumb[indexPath.row]]
                  placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"postid:%@",postid_[indexPath.row]);
}
@end
