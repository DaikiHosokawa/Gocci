//
//  CollectionViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "NearViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "UsersViewController.h"
#import "NearViewControllerCell.h"
#import "LocationClient.h"
#import "TimelinePost.h"

static NSString * const reuseIdentifier = @"Cell";
static const CGFloat kCellMargin = 5;

@interface NearViewController ()<UICollectionViewDelegateFlowLayout,NearViewCellDelegate>


@property (nonatomic,strong) NSArray *posts;

@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@implementation NearViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
    NSMutableArray *distance;
}


- (void)viewWillAppear:(BOOL)animated{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData:YES];
     self.clearsSelectionOnViewWillAppear = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupData:(BOOL)usingLocationCache
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
   
     __weak typeof(self)weakSelf = self;
    
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        NSLog(@"ここ通ったよ");
    
    [APIClient Distance:coordinate.latitude longitude:coordinate.longitude handler:^(id result, NSUInteger code, NSError *error)
     {
         NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        
        for (NSDictionary *post in result) {
             [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post]];
        }
    
          self.posts = [NSArray arrayWithArray:tempPosts];
        NSLog(@"temposts:%@",tempPosts);
        
         if ([self.posts count] == 0) {
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
        
           };
    
         // 位置情報キャッシュを使う場合で、位置情報キャッシュが存在する場合、
         // キャッシュされた位置情報を利用して API からデータを取得する
         CLLocation *cachedLocation = [LocationClient sharedClient].cachedLocation;
         if (usingLocationCache && cachedLocation != nil) {
             fetchAPI(cachedLocation.coordinate);
              NSLog(@"ここ通ったよ2");
             return;
         }

         // 位置情報キャッシュを使わない、あるいはキャッシュが存在しない場合、
         // 位置情報を取得してから API へアクセスする
         [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
          {
               NSLog(@"ここ通ったよ3");
              LOG(@"location=%@, error=%@", location, error);
              
              if (error) {
                  // 位置情報の取得に失敗
                  // TODO: アラート等を掲出
                  return;
              }
              fetchAPI(location.coordinate);
         
     }];
   
}

-(void)nearViewCell:(NearViewControllerCell *)cell didTapRestname:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
}

-(void)nearViewCell:(NearViewControllerCell *)cell didTapOptions:(NSString *)rest_id{
    NSLog(@"tap option:%@",rest_id);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NearViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // セルにデータを反映
    TimelinePost *post = self.posts[indexPath.row];
    [cell configureWithTimelinePost:post];
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
/*
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
*/

@end
