//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController_other.h"
#import "everyTableViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "everyBaseNavigationController.h"
#import "SVProgressHUD.h"
#import "TimelineCell.h"
#import "BBBadgeBarButtonItem.h"
#import "NotificationViewController.h"
#import "everyTableViewController.h"
#import "FollowListViewController.h"
#import "FolloweeListViewController.h"
#import "CheerListViewController.h"

#import "CollectionViewCell.h"

#import "everyBaseNavigationController.h"
#import "CollectionViewController.h"
#import "TableViewController.h"
#import "MapViewController.h"
#import "Swift.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_FOLLOW = @"goFollow";
static NSString * const SEGUE_GO_FOLLOWEE = @"goFollowee";
static NSString * const SEGUE_GO_CHEER = @"goCheer";

@import QuartzCore;


@protocol MovieViewDelegate;

@interface usersTableViewController_other ()
{
    NSDictionary *header;
    NSDictionary *post;
    __strong NSMutableArray *_items;
    __weak IBOutlet UISegmentedControl *segmentControll;
    __weak IBOutlet UIView *changeView;
    UIViewController *currentViewController_;
    NSArray *viewControllers_;
}
@property (nonatomic, copy) NSMutableArray *postid_;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;

@property (weak, nonatomic) IBOutlet UILabel *FollowNum;
@property (weak, nonatomic) IBOutlet UILabel *FolloweeNum;
@property (weak, nonatomic) IBOutlet UILabel *CheerNum;


/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation usersTableViewController_other

@synthesize postUsername= _postUsername;
@synthesize postPicture= _postPicture;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // !!!:dezamisystem
    //	self.navigationItem.title = _postUsername;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    _FollowNum.userInteractionEnabled = YES;
    _FollowNum.tag = 100;
    _FolloweeNum.userInteractionEnabled = YES;
    _FolloweeNum.tag = 101;
    _CheerNum.userInteractionEnabled = YES;
    _CheerNum.tag = 102;

}

//segmentcontroll
- (void)setupViewControllers
{
    UIViewController *firstViewController;
    TableViewController *vc = [[TableViewController  alloc] init];
    vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
    vc.supervc = self;
    vc.receiveDic = post;
    firstViewController = vc;
    vc.soda = changeView.frame;
    
    UIViewController *secondViewController;
    CollectionViewController *vc2 = [[CollectionViewController alloc] init];
    vc2 = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    vc2.supervc = self;
    vc2.receiveDic2 = post;
    secondViewController = vc2;
    vc2.soda = changeView.frame;
    
    UIViewController *thirdViewController;
    MapViewController *vc3 = [[MapViewController alloc] init];
    vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    vc3.receiveDic3 = post;
    NSLog(@"ここでは:%@",post);
    vc3.supervc = self;
    vc3.soda = changeView.frame;
    
    thirdViewController = vc3;
    
    viewControllers_ = @[firstViewController, secondViewController, thirdViewController];
}

- (void)changeSegmentedControlValue
{
    if(currentViewController_){
        [currentViewController_ willMoveToParentViewController:nil];
        [currentViewController_.view removeFromSuperview];
        [currentViewController_ removeFromParentViewController];
    }
    
    UIViewController *nextViewController = viewControllers_[segmentControll.selectedSegmentIndex];
    
    [self addChildViewController:nextViewController];
    nextViewController.view.frame = CGRectMake(changeView.bounds.origin.x, changeView.bounds.origin.y, changeView.bounds.size.width, changeView.bounds.size.height+9);
    [changeView addSubview:nextViewController.view];
    [nextViewController didMoveToParentViewController:self];
    
    currentViewController_ = nextViewController;
    
}


//notification

- (IBAction)changeSegmentValue:(id)sender {
    [self changeSegmentedControlValue];
}

-(IBAction)light:(id)sender {
    
    if(flash_on == 0 ){
        
        // API からデータを取得
        [APIClient postFollow:[header objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
            if ([result[@"code"] integerValue] == 200) {
                UIImage *img = [UIImage imageNamed:@"Following-Button.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 1;
                NSLog(@"フォローしました");
            }
        }
         ];
        
        
        
    }else if (flash_on == 1){
        
        [APIClient postUnFollow:[header objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
            if ((code=200)) {
                NSLog(@"フォロー解除しました");
                UIImage *img = [UIImage imageNamed:@"Follow-Button.png"];
                [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
                flash_on = 0;
            }
        }
         ];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
   
    [self _fetchProfile_other];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    
    // 動画データを一度全て削除
    //[[MoviePlayerManager sharedManager] removeAllPlayers];
    //[[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Action

- (void)refresh:(UIRefreshControl *)sender
{
    [self _fetchProfile_other];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}





#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // スクロール中は動画を停止する
    // [[MoviePlayerManager sharedManager] scrolling:YES];
    
}



- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // setContentOffset: 等によるスクロール終了
    NSLog(@"scroll is stoped");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:SEGUE_GO_EVERY_COMMENT])
    {
        //ここでパラメータを渡す
#if 0
        everyTableViewController *eveVC = segue.destinationViewController;
#else
        everyBaseNavigationController *eveNC = segue.destinationViewController;
        everyTableViewController *eveVC = (everyTableViewController*)[eveNC rootViewController];
#endif
        eveVC.postID = (NSString *)sender;
    }
    
    //店舗画面にパラメータを渡して遷移する
    // !!!:dezamisystem
    //    if ([segue.identifier isEqualToString:@"goRestpage"])
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = [header objectForKey:@"user_id"];
    }
}


#pragma mark - TimelineCellDelegate



-(void)byoga{
    
    //AppDelegate* profiledelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.profilename.text = [header objectForKey:@"username"];
    [self.profilepicture setImageWithURL:[NSURL URLWithString:[header objectForKey:@"profile_img"]]
                        placeholderImage:[UIImage imageNamed:@"default.png"]];
    self.FolloweeNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follower_num"]];
    self.FollowNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follow_num"]];
    //[header objectForKey:@"follow_num"];
    self.CheerNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"cheer_num"]];
    //[header objectForKey:@"cheer_num"];
    //_status_ = [header objectForKey:@"follow_flag"];
    //NSLog(@"statushere:%@",_status_);
    NSString *status = [header objectForKey:@"follow_flag"];
    NSInteger i =  status.integerValue;
    int pi = (int)i;
    flash_on = pi;
    
    if(flash_on == 1){
        UIImage *img = [UIImage imageNamed:@"Following-Button.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        UIImage *img = [UIImage imageNamed:@"Follow-Button.png"];
        [_flashBtn setBackgroundImage:img forState:UIControlStateNormal];
    }
    
}

#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchProfile_other
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [APIClient User:_postUsername handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSLog(@"叩かれてるよ");
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        NSLog(@"users result:%@",result);
        
        NSDictionary* headerDic = (NSDictionary*)[result valueForKey:@"header"];
        NSDictionary* postDic = (NSDictionary*)[result valueForKey:@"posts"];
        header = headerDic;
        post = postDic;
        [self byoga];
        [self setupViewControllers];
        [self changeSegmentedControlValue];
    }];
}

- (IBAction) back:(id)sender
{
    [UIView transitionWithView:self.navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ [self.navigationController popViewControllerAnimated:NO]; }
                    completion:NULL];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ( touch.view.tag == _FollowNum.tag ){
        [self performSegueWithIdentifier:@"goFollow" sender:self];
    }
    else if ( touch.view.tag == _FolloweeNum.tag ){
        [self performSegueWithIdentifier:@"goFollowee" sender:self];
    }
    else if ( touch.view.tag == _CheerNum.tag){
        [self performSegueWithIdentifier:@"goCheer" sender:self];
    }
}


@end
