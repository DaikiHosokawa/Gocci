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
#import "CollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "UsersViewController.h"

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
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setFrame:self.view.bounds];
    //self.collectionView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height- self.tabBarController.tabBar.bounds.size.height);
    NSLog(@"height:%f",self.tabBarController.tabBar.bounds.size.height);
    [self.view addSubview:self.collectionView];
     [self setupData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupData
{
   
        // 取得したデータを self.posts に格納
        thumb = [NSMutableArray arrayWithCapacity:0];
        postid_ = [NSMutableArray arrayWithCapacity:0];
        restname = [NSMutableArray arrayWithCapacity:0];
        
        NSArray* items = (NSArray*)_receiveDic2;
        
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
            CGSize boundsSize = self.soda.size;
            iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
            [self.view addSubview:iv];
        }else{
            [self.collectionView reloadData];
        }
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_receiveDic2 count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:thumb[indexPath.row]]
                  placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    cell.imageView.layer.cornerRadius = 5;
    cell.imageView.clipsToBounds = true;
    cell.title.text = restname[indexPath.row];
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"postid:%@",postid_[indexPath.row]);
    [self.supervc performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postid_[indexPath.row]];
}

- (void)_fetchProfile
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    NSLog(@"3です");
    
    [APIClient User:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSLog(@"4です");
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        NSLog(@"users result:%@",result);
        
        NSDictionary* headerDic = (NSDictionary*)[result valueForKey:@"header"];
        NSDictionary* postDic = (NSDictionary*)[result valueForKey:@"posts"];
        
        // 取得したデータを self.posts に格納
        thumb = [NSMutableArray arrayWithCapacity:0];
        postid_ = [NSMutableArray arrayWithCapacity:0];
        restname = [NSMutableArray arrayWithCapacity:0];
        
        NSArray* items = (NSArray*)_receiveDic2;
        
        for (NSDictionary *post in items) {
            
            NSDictionary *thumbGet = [post objectForKey:@"thumbnail"];
            [thumb addObject:thumbGet];
            NSDictionary *postidGet = [post objectForKey:@"post_id"];
            [postid_ addObject:postidGet];
            NSDictionary *restnameGet = [post objectForKey:@"restname"];
            [restname addObject:restnameGet];
        }
        
    }];
}


/*
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
*/

@end
