//
//  FollowViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "FollowViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "AFNetworking.h"
#import "everyTableViewController.h"
#import "UsersViewController.h"
#import "FollowViewControllerCell.h"
#import "LocationClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "APIClient.h"
#import "TimelinePageMenuViewController.h"
#import "RHRefreshControl.h"
#import "SGActionView.h"

static NSString * const reuseIdentifier = @"Cell";

@interface FollowViewController ()<UICollectionViewDelegateFlowLayout,FollowViewCellDelegate,UIScrollViewDelegate,UIActionSheetDelegate,RHRefreshControlDelegate>


@property (copy, nonatomic) NSMutableArray *posts;

//refresh control
@property (nonatomic, strong) RHRefreshControl *refreshControl;
@property (nonatomic, assign, getter = isLoading) BOOL loading;

@end

static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";

@implementation FollowViewController{
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
    
    [self setupData:@"" value_id:@""];
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



- (void)setupData:(NSString *)category_id value_id:(NSString*)value_id
{
    [APIClient Follow:@"" category_id:category_id value_id:value_id  handler:^(id result, NSUInteger code, NSError *error)
     {
         if (error) {
             NSLog(@"ERROR: Network communication: %@",error);
             return;
         }
         if (!result || [result[@"code"] integerValue] != 200) {
             NSLog(@"ERROR: Network communication: server side failed for unnknown reasons");
             return;
         }
         
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
             // 画面が隠れた際に再生中の動画を停止させる
             [[MoviePlayerManager sharedManager] stopMovie];
         }
         
     }];
}


- (void)addBottom:(BOOL)usingLocationCache category_id:(NSString *)category_id value_id:(NSString*)value_id
{
    
    [self refreshFeed];
    
        NSString *str = [NSString stringWithFormat:@"%d",call];
        [APIClient Follow:str category_id:category_id value_id:value_id  handler:^(id result, NSUInteger code, NSError *error)
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
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 call++;
                 // 動画データを一度全て削除
                 // 画面が隠れた際に再生中の動画を停止させる
                 [[MoviePlayerManager sharedManager] stopMovie];
                 
                 
             }
             
         }];
}

-(void)followViewCell:(FollowViewControllerCell *)cell didTapRestname:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
    TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
    [self.delegate follow:self rest_id:rest_id];
    [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:rest_id];
}

-(void)followViewCell:(FollowViewControllerCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id{
    
    optionDic = [NSMutableDictionary dictionary];
    [optionDic setObject:rest_id forKey:@"RESTID"];
    [optionDic setObject:post_id forKey:@"POSTID"];
    [optionDic setObject:user_id forKey:@"USERID"];

    
    [SGActionView showGridMenuWithTitle:@"アクション"
                             itemTitles:@[ @"Facebook", @"Twitter", @"店舗", @"ユーザー",
                                           @"違反報告" ]
                                 images:@[ [UIImage imageNamed:@"pin"],
                                           [UIImage imageNamed:@"pin"],
                                           [UIImage imageNamed:@"pin"],
                                           [UIImage imageNamed:@"pin"],
                                           [UIImage imageNamed:@"pin"]]
                         selectedHandle:^(NSInteger index){
                             
                             NSString *u_id = [optionDic objectForKey:@"USERID"];
                             NSString *r_id = [optionDic objectForKey:@"RESTID"];
                             NSString *p_id = [optionDic objectForKey:@"POSTID"];
                             
                             TimelinePageMenuViewController *vc = (TimelinePageMenuViewController*)self.delegate;
                             
                             
                             if(index == 1){
                                 NSLog(@"Facebook");
                             }
                             else if(index == 2){
                             NSLog(@"Twitter");
                             }
                             else if(index == 3){
                                 NSLog(@"Rest");
                                 [self.delegate follow:self rest_id:r_id];
                                 [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:r_id];
                             }
                             else if(index == 4){
                                 NSLog(@"User");
                                 [self.delegate follow:self username:u_id];
                                 [vc performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:u_id];
                             }
                             else if(index == 5){
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
                             }
               }];

}

-(void)followViewCell:(FollowViewControllerCell *)cell didTapThumb:(NSString *)rest_id{
    NSLog(@"restid:%@",rest_id);
}

-(void)followViewCell:(FollowViewControllerCell *)cell didTapLikeButton:(NSString *)postID{
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
    
    FollowViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    for (UIView *subview in [cell.imageView subviews]) {
        [subview removeFromSuperview];
    }
    
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
                NSLog(@"User");
                [self.delegate follow:self username:u_id];
                [vc performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:u_id];
                break;
            case 1:
                NSLog(@"Rest");
                [self.delegate follow:self rest_id:r_id];
                [vc performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:r_id];
                break;
            case 2:
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
