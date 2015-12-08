//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import "NearViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "MypageViewController.h"
#import "NearViewControllerCell.h"
#import "LocationClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "APIClient.h"
#import "TimelinePageMenuViewController.h"
#import "RHRefreshControl.h"
#import "SGActionView.h"

static NSString * const reuseIdentifier = @"Cell";
@interface NearViewController ()<UICollectionViewDelegateFlowLayout,NearViewCellDelegate,UIScrollViewDelegate,RHRefreshControlDelegate,UIAlertViewDelegate>


@property (copy, nonatomic) NSMutableArray *posts;

//refresh control
@property (nonatomic, strong) RHRefreshControl *refreshControl;
@property (nonatomic, assign, getter = isLoading) BOOL loading;

@end

static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@implementation NearViewController{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
    NSMutableArray *distance;
    NSMutableDictionary *optionDic;
    //flag
    NSString *category_flag;
    NSString *value_flag;
    int call;
}


- (void)viewWillAppear:(BOOL)animated{
    call = 1;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    call = 0;
    category_flag = @"";
    NSLog(@"called viewwill dissa");
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] removeAllPlayers];
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
        self.clearsSelectionOnViewWillAppear = NO;
        [self.collectionView setBounces:YES];
        RHRefreshControlConfiguration *refreshConfiguration = [[RHRefreshControlConfiguration alloc] init];
        refreshConfiguration.refreshView = RHRefreshViewStylePinterest;
        self.refreshControl = [[RHRefreshControl alloc] initWithConfiguration:refreshConfiguration];
        self.refreshControl.delegate = self;
        [self.refreshControl attachToScrollView:self.collectionView];
        [self setupData:@"" value_id:@""];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setupData:(NSString *)category_id value_id:(NSString*)value_id
{
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        
        [APIClient Distance:coordinate.latitude longitude:coordinate.longitude call:@"" category_id:category_id value_id:value_id handler:^(id result, NSUInteger code, NSError *error)
         {
             NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
             
             for (NSDictionary *post in result) {
                 [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post]];
             }
             
             self.posts = tempPosts;
             
             if ([self.posts count] == 0) {
                 // 画像表示例文
                 UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
                 UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                 CGSize boundsSize = self.view.bounds.size;
                 iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
                 [self.view addSubview:iv];
             }else{
                 [self.collectionView reloadData];
                 [self performSelector:@selector(_fakeLoadComplete) withObject:nil];
                 // 画面が隠れた際に再生中の動画を停止させる
                 [[MoviePlayerManager sharedManager] stopMovie];
                 
             }
             
         }];
        
    };
    
    [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error)
     {
         
         if (error) {
             return;
         }
         fetchAPI(location.coordinate);
         
     }];
    
}


- (void)addBottom:(BOOL)usingLocationCache category_id:(NSString *)category_id value_id:(NSString*)value_id
{
    
    [self refreshFeed];
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        NSString *str = [NSString stringWithFormat:@"%d",call];
        [APIClient Distance:coordinate.latitude longitude:coordinate.longitude call:str category_id:category_id value_id:value_id  handler:^(id result, NSUInteger code, NSError *error)
         {
             NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
             
             NSLog(@"add Login:%@",result);
             
             for (NSDictionary *post in result) {
                 [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post]];
             }
             NSMutableArray *newArray = [self.posts mutableCopy];
             [newArray addObjectsFromArray:tempPosts];
             
             self.posts = newArray;
             
             if ([self.posts count] == 0) {
                 UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
                 UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                 CGSize boundsSize = self.view.bounds.size;
                 iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
                 [self.view addSubview:iv];
             }else{
                 [self.collectionView reloadData];
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 call++;
                 [[MoviePlayerManager sharedManager] stopMovie];
                 
             }
             
         }];
        
    };
    
    CLLocation *cachedLocation = [LocationClient sharedClient].cachedLocation;
    if (usingLocationCache && cachedLocation != nil) {
        fetchAPI(cachedLocation.coordinate);
        NSLog(@"ここ通ったよ2");
        return;
    }
    
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
    TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
    [self.delegate near:self rest_id:rest_id];
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:rest_id];
}

-(void)nearViewCell:(NearViewControllerCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id{
    optionDic = [NSMutableDictionary dictionary];
    [optionDic setObject:rest_id forKey:@"RESTID"];
    [optionDic setObject:post_id forKey:@"POSTID"];
    [optionDic setObject:user_id forKey:@"USERID"];
    
    
    [SGActionView showGridMenuWithTitle:@"アクション"
                             itemTitles:@[@"Twitter", @"店舗", @"ユーザー",
                                          @"違反報告" ]
                                 images:@[ [UIImage imageNamed:@"twitter"],
                                           [UIImage imageNamed:@"restaurant"],
                                           [UIImage imageNamed:@"man"],
                                           [UIImage imageNamed:@"warning"]]
                         selectedHandle:^(NSInteger index){
                             
                             NSString *u_id = [optionDic objectForKey:@"USERID"];
                             NSString *r_id = [optionDic objectForKey:@"RESTID"];
                             NSString *p_id = [optionDic objectForKey:@"POSTID"];
                             
                             TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
                             
                             
                             if(index == 1){
                                 NSLog(@"Twitter");
                             }
                             else if(index == 2){
                                 NSLog(@"Rest");
                                 [self.delegate near:self rest_id:r_id];
                                 [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:r_id];
                             }
                             else if(index == 3){
                                 NSLog(@"User");
                                 [self.delegate near:self username:u_id];
                                 [vc performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:u_id];
                             }
                             else if(index == 4){
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
                                 }
                             }
                         }];
    

    }

-(void)nearViewCell:(NearViewControllerCell *)cell didTapThumb:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
}

-(void)nearViewCell:(NearViewControllerCell *)cell didTapLikeButton:(NSString *)postID{
    [APIClient postGood:postID handler:^(id result, NSUInteger code, NSError *error) {
        if (result) {
            NSLog(@"result:%@",result);
        }
    }
     ];
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NearViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    for (UIView *subview in [cell.imageView subviews]) {
        [subview removeFromSuperview];
    }
    
    TimelinePost *post = self.posts[indexPath.row];
    [cell configureWithTimelinePost:post indexPath:indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [self.refreshControl refreshScrollViewDidScroll:scrollView];
    
    if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height))
    {
        NSLog(@"Requesting API ? %@", [UIApplication         sharedApplication].networkActivityIndicatorVisible ? @"YES" : @"NO");
        if (![UIApplication sharedApplication].networkActivityIndicatorVisible ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            if([category_flag length]>0 && [value_flag length]>0){
                
                [self addBottom:YES category_id:category_flag value_id:value_flag];
            }else{
                
                if ([category_flag length]>0) {
                    [self addBottom:YES category_id:category_flag value_id:@""];
                }else if ([value_flag length]>0){
                    [self addBottom:YES category_id:@"" value_id:value_flag];
                }else{
                    //一番下
                    [self addBottom:YES category_id:@"" value_id:@""];
                }
            }
        }
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self.refreshControl refreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark - RHRefreshControl Delegate
- (void)refreshDidTriggerRefresh:(RHRefreshControl *)refreshControl {
    
    self.loading = YES;
    
    if([category_flag length]>0 && [value_flag length]>0){
        
        [self setupData:category_flag value_id:value_flag];
    }else{
        
        if ([category_flag length]>0) {
            [self setupData:category_flag value_id:@""];
        }else if ([value_flag length]>0){
            [self setupData:@"" value_id:value_flag];
        }else{
            //一番下
            [self setupData:@"" value_id:@""];
        }
    }
    
}

- (BOOL)refreshDataSourceIsLoading:(RHRefreshControl *)refreshControl {
    return self.isLoading; 
    
}

- (void) _fakeLoadComplete {
    self.loading = NO;
    [self.refreshControl refreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
}


- (void)sortFunc:(NSString *)category {
    category_flag = category;
    if ([value_flag length]>0) {
        [self setupData:category value_id:value_flag];
    }else{
        [self setupData:category value_id:@""];
    }
}

- (void)sortValue:(NSString *)value {
    value_flag = value;
    if ([category_flag length]>0) {
        [self setupData:category_flag value_id:value];
    }
    [self setupData:@"" value_id:value];
}

- (void)refreshFeed {
    
    
}



#pragma mark - UICollectionViewDelegate


@end
