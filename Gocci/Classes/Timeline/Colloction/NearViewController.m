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
#import "MoviePlayerManager.h"
#import "APIClient.h"
#import "TimelinePageMenuViewController.h"
#import "RHRefreshControl.h"

static NSString * const reuseIdentifier = @"Cell";
static const CGFloat kCellMargin = 5;

@interface NearViewController ()<UICollectionViewDelegateFlowLayout,NearViewCellDelegate,UIScrollViewDelegate,UIActionSheetDelegate,RHRefreshControlDelegate>


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
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupData:YES category_id:@"" value_id:@""];
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.collectionView setBounces:YES];
    
    RHRefreshControlConfiguration *refreshConfiguration = [[RHRefreshControlConfiguration alloc] init];
    refreshConfiguration.refreshView = RHRefreshViewStylePinterest;
    
    //  refreshConfiguration.minimumForStart = @0;
    //  refreshConfiguration.maximumForPull = @120;
    self.refreshControl = [[RHRefreshControl alloc] initWithConfiguration:refreshConfiguration];
    self.refreshControl.delegate = self;
    [self.refreshControl attachToScrollView:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setupData:(BOOL)usingLocationCache category_id:(NSString *)category_id value_id:(NSString*)value_id
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    
    void(^fetchAPI)(CLLocationCoordinate2D coordinate) = ^(CLLocationCoordinate2D coordinate)
    {
        
        [APIClient Distance:coordinate.latitude longitude:coordinate.longitude call:@"" category_id:category_id value_id:value_id handler:^(id result, NSUInteger code, NSError *error)
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
                 [self performSelector:@selector(_fakeLoadComplete) withObject:nil];
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


- (void)addBottom:(BOOL)usingLocationCache category_id:(NSString *)category_id value_id:(NSString*)value_id
{
    
    [self refreshFeed];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    
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
                 // 画像表示例文
                 UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
                 UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                 CGSize boundsSize = self.view.bounds.size;
                 iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
                 [self.view addSubview:iv];
             }else{
                 [self.collectionView reloadData];
                 // 動画データを一度全て削除
                 [[MoviePlayerManager sharedManager] removeAllPlayers];
                 
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
    TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
    [self.delegate near:self rest_id:rest_id];
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:rest_id];
}

-(void)nearViewCell:(NearViewControllerCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id{
    
    UIActionSheet *actionsheet = nil;
    
    optionDic = [NSMutableDictionary dictionary];
    [optionDic setObject:rest_id forKey:@"RESTID"];
    [optionDic setObject:post_id forKey:@"POSTID"];
    [optionDic setObject:user_id forKey:@"USERID"];
    
    actionsheet = [[UIActionSheet alloc] initWithTitle:@"アクション"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"このユーザーに質問する",@"Facebookでシェアする",@"Twitterでシェアする",@"Instagramでシェアする",@"ユーザーページへ移動",@"レストランページへ移動",@"この投稿を問題として報告" ,nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.view];
    
}

-(void)nearViewCell:(NearViewControllerCell *)cell didTapThumb:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
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
    [cell configureWithTimelinePost:post indexPath:indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [self.refreshControl refreshScrollViewDidScroll:scrollView];
    
    //一番下までスクロールしたかどうか
    if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height))
    {
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


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self.refreshControl refreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark - RHRefreshControl Delegate
- (void)refreshDidTriggerRefresh:(RHRefreshControl *)refreshControl {
    
    self.loading = YES;
    
    if([category_flag length]>0 && [value_flag length]>0){
        
        [self setupData:YES category_id:category_flag value_id:value_flag];
    }else{
        
        if ([category_flag length]>0) {
            [self setupData:YES category_id:category_flag value_id:@""];
        }else if ([value_flag length]>0){
            [self setupData:YES category_id:@"" value_id:value_flag];
        }else{
            //一番下
            [self setupData:YES category_id:@"" value_id:@""];
        }
    }
    
}

- (BOOL)refreshDataSourceIsLoading:(RHRefreshControl *)refreshControl {
    return self.isLoading; // should return if data source model is reloading
    
}

- (void) _fakeLoadComplete {
    self.loading = NO;
    [self.refreshControl refreshScrollViewDataSourceDidFinishedLoading:self.collectionView];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"%s sheet = %ld",__func__, (long)buttonIndex);
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"cancel");
    }
    else {
        NSString *u_id = [optionDic objectForKey:@"USERID"];
        NSString *r_id = [optionDic objectForKey:@"RESTID"];
        NSString *p_id = [optionDic objectForKey:@"POSTID"];
        
        TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
        
        
        switch (buttonIndex) {
            case 0:
                NSLog(@"質問");
                break;
            case 1:
                NSLog(@"Facebook");
                break;
            case 2:
                NSLog(@"Twitter");
                break;
            case 3:
                NSLog(@"Instagram");
                break;
            case 4:
                NSLog(@"User");
                [self.delegate near:self username:u_id];
                [vc performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:u_id];
                break;
            case 5:
                NSLog(@"Rest");
                [self.delegate near:self rest_id:r_id];
                [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:r_id];
                break;
            case 6:
                NSLog(@"Problem");
                
                Class class = NSClassFromString(@"UIAlertController");
                if(class)
                {
                    // iOS 8の時の処理
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を違反報告しますか？" preferredStyle:UIAlertControllerStyleAlert];
                    
                    // addActionした順に左から右にボタンが配置されます
                    [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        // API からデータを取得
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
                
                break;
            default:
                break;
        }
        
    }
}

- (void)sortFunc:(NSString *)category {
    category_flag = category;
    if ([value_flag length]>0) {
        [self setupData:YES category_id:category value_id:value_flag];
    }else{
        [self setupData:YES category_id:category value_id:@""];
    }
}

- (void)sortValue:(NSString *)value {
    value_flag = value;
    if ([category_flag length]>0) {
        [self setupData:YES category_id:category_flag value_id:value];
    }
    [self setupData:YES category_id:@"" value_id:value];
}

- (void)refreshFeed {
    
    
}


#pragma mark - UICollectionViewDelegate


@end
