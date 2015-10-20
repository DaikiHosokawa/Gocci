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

@interface NearViewController ()<UICollectionViewDelegateFlowLayout,NearViewCellDelegate,UIScrollViewDelegate>


@property (copy, nonatomic) NSMutableArray *posts;

@end

static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@implementation NearViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
    NSMutableArray *distance;
    int call;
    
}


- (void)viewWillAppear:(BOOL)animated{
    call = 1;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupData:YES];
     self.clearsSelectionOnViewWillAppear = NO;
    UIImage *img = [UIImage imageNamed:@"ic_userpicture.png"];  // ボタンにする画像を生成する
    UIButton *btn = [[UIButton alloc]
                     initWithFrame:CGRectMake(self.view.frame.size.width - 72, self.view.frame.size.height - 90, 56, 56)];  // ボタンのサイズを指定する
    [btn setBackgroundImage:img forState:UIControlStateNormal];  // 画像をセットする
    [self.parentViewController.parentViewController.view addSubview:btn];
    // ボタンが押された時にhogeメソッドを呼び出す
    [btn addTarget:self
            action:@selector(hoge) forControlEvents:UIControlEventTouchUpInside];
    
    
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
        
        [APIClient Distance:coordinate.latitude longitude:coordinate.longitude call:@"" handler:^(id result, NSUInteger code, NSError *error)
     {
         NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        
        for (NSDictionary *post in result) {
             [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post]];
        }
    
         self.posts = tempPosts;
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
            
             return;
         }

         // 位置情報キャッシュを使わない、あるいはキャッシュが存在しない場合、
         // 位置情報を取得してから API へアクセスする
         [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
          {
              
              if (error) {
                  // 位置情報の取得に失敗
                  // TODO: アラート等を掲出
                  return;
              }
              fetchAPI(location.coordinate);
         
     }];
   
}


- (void)setupDataAgain:(BOOL)usingLocationCache
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        NSString *str = [NSString stringWithFormat:@"%d",call];
        [APIClient Distance:coordinate.latitude longitude:coordinate.longitude call:str handler:^(id result, NSUInteger code, NSError *error)
         {
             NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
             
             for (NSDictionary *post in result) {
                 [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post]];
             }
             NSMutableArray *newArray = [self.posts mutableCopy];
             [newArray addObjectsFromArray:tempPosts];
             
             self.posts = newArray;
             
             if ([self.posts count] == 0) {
                 // 画像表示例文
                 UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
                 UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                 CGSize boundsSize = self.view.bounds.size;
                 iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
                 [self.view addSubview:iv];
             }else{
                 [self.collectionView reloadData];
                 call++;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //一番下までスクロールしたかどうか
    if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height))
    {
       //一番下
        [self setupDataAgain:YES];
    }
}


#pragma mark - UICollectionViewDelegate


@end
