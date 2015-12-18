//
//  RestaurantTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "RestaurantTableViewController.h"
#import "everyTableViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelineCell.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import <GoogleMaps/GoogleMaps.h>
#import "everyBaseNavigationController.h"
#import "NotificationViewController.h"
#import "RHRefreshControl.h"

static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_SC_RECORDER = @"goSCRecorder";

@import AVFoundation;
@import QuartzCore;

@protocol MovieViewDelegate;

@interface RestaurantTableViewController ()
<TimelineCellDelegate,MKMapViewDelegate,RHRefreshControlDelegate>
{
    __weak IBOutlet MKMapView *map_;
    NSDictionary *header;
}


@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, strong) RHRefreshControl *refresh;
@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (nonatomic,strong) NSArray *posts;

@end


@implementation RestaurantTableViewController
{
    NSString *_text, *_hashTag;
}
@synthesize postRestName = _postRestName;;


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
        
    }
    
    self.tableView.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:234.0/255.0 blue:234.0/255.0 alpha:1.0];
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimelineCell" bundle:nil]
         forCellReuseIdentifier:TimelineCellIdentifier];

    RHRefreshControlConfiguration *refreshConfiguration = [[RHRefreshControlConfiguration alloc] init];
    refreshConfiguration.refreshView = RHRefreshViewStylePinterest;
    self.refresh = [[RHRefreshControl alloc] initWithConfiguration:refreshConfiguration];
    self.refresh.delegate = self;
    [self.refresh attachToScrollView:self.tableView];
    [self _fetchRestaurant];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.002, 0.002);
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, span);
    [map_ setRegion:region animated:NO];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

#pragma mark - RHRefreshControl Delegate
- (void)refreshDidTriggerRefresh:(RHRefreshControl *)refreshControl {
    
    self.loading = YES;
     [self _fetchRestaurant];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refresh refreshScrollViewDidScroll:self.tableView];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[MoviePlayerManager sharedManager] stopMovie];
    [[MoviePlayerManager sharedManager] removeAllPlayers];
    [super viewWillDisappear:animated];
 //   [self.navigationController setNavigationBarHidden:YES animated:NO];
}


#pragma mark - Action




- (IBAction)unwindToTop:(UIStoryboardSegue *)segue
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TimelineCell cellHeightWithTimelinePost:self.posts[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = TimelineCellIdentifier;
    TimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [TimelineCell cell];
    }
    
    cell.delegate = self;
    
    TimelinePost *post = self.posts[indexPath.row];
    [cell configureWithTimelinePost:post];
    
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL f){}];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.85];
}


-(id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return [NSString stringWithFormat:@"%@ #%@", _text, _hashTag];
    }
    return _text;
}


-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return _text;
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refresh refreshScrollViewDidEndDragging:self.tableView];
    
    if(!decelerate) {
        [self _playMovieAtCurrentCell];
    }
}

- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
    {
#if 0
        everyTableViewController *eveVC = segue.destinationViewController;
#else
        everyBaseNavigationController *eveNC = segue.destinationViewController;
        everyTableViewController *eveVC = (everyTableViewController*)[eveNC rootViewController];
        [self.popover dismissPopoverAnimated:YES];
#endif
        eveVC.postID = (NSString *)sender;
        [self.popover dismissPopoverAnimated:YES];
    }
    
    if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
    {
        UserpageViewController *userVC = segue.destinationViewController;
         userVC.postUsername = _postUsername;
    }
}

- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID
{   
    [APIClient postGood:postID handler:^(id result, NSUInteger code, NSError *error) {
    }
     ];
    
}


- (void)timelineCell:(TimelineCell *)cell didTapViolateButtonWithPostID:(NSString *)postID
{
    
    Class class = NSClassFromString(@"UIAlertController");
    if(class)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を違反報告しますか？" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [APIClient postBlock:postID handler:^(id result, NSUInteger code, NSError *error) {
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
        [APIClient postBlock:postID handler:^(id result, NSUInteger code, NSError *error) {
            if (result) {
                NSString *alertMessage = @"違反報告をしました";
                UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alrt show];
            }
        }
         ];
    }
}

-(IBAction)light:(id)sender {
    
    if(flash_on == 0 ){
        
        [APIClient postWant:[header objectForKey:@"restname"] handler:^(id result, NSUInteger code, NSError *error) {
            
            if (code != 200 || error != nil) {
                return;
            }else{
                UIImage *img = [UIImage imageNamed:@"Oen.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 1;
                
            }
    
            }];
        
    }else if (flash_on == 1){
        [APIClient postUnWant:[header objectForKey:@"restname"] handler:^(id result, NSUInteger code, NSError *error) {
            
            if (code != 200 || error != nil) {
                
                return;
            }else{
                UIImage *img = [UIImage imageNamed:@"notOen.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 0;
            }
        }];
    }
}

- (IBAction)tapTEL {
    if ([[header objectForKey:@"tell"] isEqualToString:@"非公開"] || [[header objectForKey:@"tell"] isEqualToString:@"準備中"]|| [[header objectForKey:@"tell"] isEqualToString:@"予約不可"]|| [[header objectForKey:@"tell"] isEqualToString:@"非設置"]|| [[header objectForKey:@"tell"] isEqualToString:@"none"]) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"申し訳ありません。電話番号が登録されておりません"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        NSString *number = @"tel:";
        NSString *telstring = [NSString stringWithFormat:@"%@%@",number,[header objectForKey:@"tell"]];
        NSURL *url = [[NSURL alloc] initWithString:telstring];
        [[UIApplication sharedApplication] openURL:url];
        
    }
}


- (IBAction)tapNavi:(id)sender {
    NSString *mapText = [header objectForKey:@"restname"];
    NSString *mapText2 = [header objectForKey:@"locality"];
    mapText = [mapText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    mapText2  = [mapText2 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *directions = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@&zoom=18&directionsmode=walking",mapText2];
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:directions]];
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ナビゲーション使用にはGoogleMapのアプリが必要です"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)tapHomepatge {
    NSString *urlString = [header objectForKey:@"homepage"];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark コメントボタン押下時の処理
- (void)timelineCell:(TimelineCell *)cell didTapCommentButtonWithPostID:(NSString *)postID
{
    _postID = postID;
    [self performSegueWithIdentifier:SEGUE_GO_EVERY_COMMENT sender:postID];
}


#pragma mark user_nameタップの時の処理
- (void)timelineCell:(TimelineCell *)cell didTapUserName:(NSString *)user_id
{
    _postUsername = user_id;
    [self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
}

-(void)timelineCell:(TimelineCell *)cell didTapNaviWithLocality:(NSString *)Locality
{
    NSString *mapText = Locality;
    mapText  = [mapText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *directions = [NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%@&zoom=18&directionsmode=walking",mapText];
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:directions]];
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"ナビゲーション使用にはGoogleMapのアプリが必要です"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
    }
}


#pragma mark user_nameタップの時の処理②
- (void)timelineCell:(TimelineCell *)cell didTapPicture:(NSString *)user_id
{
    _postUsername = user_id;
    
}

-(void)byoga{
    self.restname.text = [header objectForKey:@"restname"];
    self.categoryLabel.text = [header objectForKey:@"rest_category"];
    
    NSString *postLat = [header objectForKey:@"lat"];
    double latdo = postLat.doubleValue;
    _coordinate.latitude = latdo;
    
    NSString *postLon = [header objectForKey:@"lon"];
    double londo = postLon.doubleValue;
    _coordinate.longitude = londo;
    
    self.total_cheer_num.text = [NSString stringWithFormat:@"%@", [header objectForKey:@"cheer_num"]];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latdo
                                                            longitude:londo
                                                                 zoom:18];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.title = [header objectForKey:@"restname"];
    marker.snippet = [header objectForKey:@"locality"];
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map  = _map;
    _map.selectedMarker = marker;
    [_map setCamera:camera];
    
    NSString *postWanttag = [header objectForKey:@"want_flag"];
    NSInteger i = postWanttag.integerValue;
    int pi = (int)i;
    flash_on = pi;
    
    if(flash_on == 1){
        
        UIImage *img = [UIImage imageNamed:@"Oen.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
        
    }else{
        
        UIImage *img = [UIImage imageNamed:@"notOen.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [SVProgressHUD dismiss];
    
}

#pragma mark - Private Methods


- (void)_fetchRestaurant
{
    [SVProgressHUD show];
    
    __weak typeof(self)weakSelf = self;
    [APIClient Restaurant:_postRestName handler:^(id result, NSUInteger code, NSError *error) {
        
        if (code != 200 || error != nil) {
            return;
        }
        
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        NSArray* items = (NSArray*)[result valueForKey:@"posts"];
        NSDictionary* restaurants = (NSDictionary*)[result valueForKey:@"restaurants"];
        
        for (NSDictionary *dict in items) {
            [tempPosts addObject:[TimelinePost timelinePostWithDictionary:dict]];
        }
        
        header = restaurants;
        self.posts = [NSArray arrayWithArray:tempPosts];
        [[MoviePlayerManager sharedManager] removeAllPlayers];
        [weakSelf.tableView reloadData];
        
        if ([self.posts count]== 0) {
            [SVProgressHUD dismiss];
        }
        [self performSelector:@selector(_fakeLoadComplete) withObject:nil];
        [self byoga];
    }];
}


- (void)_playMovieAtCurrentCell
{
    
    if ( [self.posts count] == 0){
        return;
    }
    CGFloat currentHeight = 0.0;
    for (NSUInteger i=0; i < [self _currentIndexPath].row; i++) {
        if ([self.posts count] <= i) continue;
        
        currentHeight += [TimelineCell cellHeightWithTimelinePost:self.posts[i]];
    }
    
    TimelineCell *currentCell = [TimelineCell cell];
    [currentCell configureWithTimelinePost:self.posts[[self _currentIndexPath].row]];
    CGRect movieRect = CGRectMake((self.tableView.frame.size.width - currentCell.thumbnailView.frame.size.width) / 2,
                                  currentHeight + currentCell.thumbnailView.frame.origin.y+self.headerView.bounds.size.height,
                                  currentCell.thumbnailView.frame.size.width,
                                  currentCell.thumbnailView.frame.size.height);
    
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:movieRect];
    
}


- (NSIndexPath *)_currentIndexPath
{
    CGPoint point = CGPointMake(self.tableView.contentOffset.x,
                                self.tableView.contentOffset.y + self.tableView.frame.size.height/2);
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point];
    
    return currentIndexPath;
}

- (IBAction)onOther:(UIButton *)sender {
    
    UIActionSheet *actionsheet = nil;
    actionsheet = [[UIActionSheet alloc] initWithTitle:@"その他"
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                     otherButtonTitles:@"ホームページを見る",nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
    }else if(buttonIndex == 0) {
        if ([[header objectForKey:@"homepage"] isEqualToString:@"none"]||[[header objectForKey:@"homepage"] isEqualToString:@"準備中"]) {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"申し訳ありません。ホームページが登録されておりません"
                                      delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[header objectForKey:@"homepage"]]];
        }
    }
}

#pragma mark - 投稿するボタン
- (IBAction)onPostingButton:(id)sender {
    
    self.tabBarController.selectedIndex = 2;
    
}

- (BOOL)refreshDataSourceIsLoading:(RHRefreshControl *)refreshControl {
    return self.isLoading;
    
}

- (void) _fakeLoadComplete {
    self.loading = NO;
    [self.refresh refreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}




@end
