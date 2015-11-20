//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "UsersViewController.h"
#import "everyTableViewController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "MoviePlayerManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "FollowListViewController.h"
#import "FolloweeListViewController.h"
#import "CheerListViewController.h"
#import "TimelineCell.h"
#import "NotificationViewController.h"

@import QuartzCore;

#import "everyBaseNavigationController.h"
#import "TableViewController.h"
#import "MapViewController.h"
#import "Swift.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";
static NSString * const SEGUE_GO_EVERY_COMMENT = @"goEveryComment";
static NSString * const SEGUE_GO_FOLLOW = @"goFollow";
static NSString * const SEGUE_GO_FOLLOWEE = @"goFollowee";
static NSString * const SEGUE_GO_CHEER = @"goCheer";

@protocol MovieViewDelegate;

@interface UsersViewController ()<CollectionViewControllerDelegate1>
{
    NSDictionary *header;
    NSDictionary *post;
    NSMutableArray *post1;
    __weak IBOutlet UIButton *editButton;
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
@property (weak, nonatomic) IBOutlet UIButton *badgeButton;

@end

@implementation UsersViewController

-(void)collection:(CollectionViewController *)vc postid:(NSString *)postid
{
    _postID = postid;
}

-(void)collection:(CollectionViewController *)vc rest_id:(NSString *)rest_id
{
    _postRestname = rest_id;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self _fetchProfile];
    [segmentControll setSelectedSegmentIndex:0];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.badgeButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //BackButton
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    
    self.navigationItem.backBarButtonItem = backButton;

    //editButton
    editButton.layer.cornerRadius = 10; // this value vary as per your desire
    editButton.clipsToBounds = YES;
    
    //segmentControll
   // [segmentControll setFrame:CGRectMake(-6, 137, 387, 40)];
    
     _FollowNum.userInteractionEnabled = YES;
    _FollowNum.tag = 100;
    _FolloweeNum.userInteractionEnabled = YES;
    _FolloweeNum.tag = 101;
    _CheerNum.userInteractionEnabled = YES;
    _CheerNum.tag = 102;
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];
    [[MoviePlayerManager sharedManager] removeAllPlayers];
    [super viewWillDisappear:animated];
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
    vc2.receiveDic2 = post1;
    vc2.delegate = self;
    secondViewController = vc2;
    vc2.soda = changeView.frame;
    
    UIViewController *thirdViewController;
    MapViewController *vc3 = [[MapViewController alloc] init];
    vc3 = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    vc3.receiveDic3 = post;
    vc3.supervc = self;
    vc3.soda = changeView.frame;

    thirdViewController = vc3;
   
    viewControllers_ = @[firstViewController, secondViewController, thirdViewController];
}

- (void)changeSegmentedControlValue
{
    if(segmentControll.selectedSegmentIndex == 2){
       [self performSegueWithIdentifier:@"goMap" sender:self];
    }else{
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
}


//notification

- (IBAction)changeSegmentValue:(id)sender {
    [self changeSegmentedControlValue];
}

- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
    
}

-(void)barButtonItemPressed:(id)sender{
    
  
    if (!self.popover) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
        vc.supervc = self;
        self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    }
    
    [self.popover presentPopoverFromRect:CGRectMake(
                                                    self.badgeButton.accessibilityFrame.origin.x + 15, self.badgeButton.accessibilityFrame.origin.y + 30, self.badgeButton.accessibilityFrame.size.width, self.badgeButton.accessibilityFrame.size.height)
                                  inView:self.badgeButton
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
    
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    
    if ([segue.identifier isEqualToString:@"goMap"])
    {
        //ここでパラメータを渡す
        MapViewController  *mapVC = segue.destinationViewController;
        mapVC.receiveDic3 = post;
    }
    
}


- (void)_fetchProfile
{
    [APIClient User:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {

        if (code != 200 || error != nil) {
            return;
        }
        NSLog(@"users result:%@",result);
         NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
         NSArray* items = (NSArray*)[result valueForKey:@"posts"];
         
         for (NSDictionary *post2 in items) {
             [tempPosts addObject:[TimelinePost timelinePostWithDictionary:post2]];
         }
         post1 = tempPosts;
        
        NSDictionary* headerDic = (NSDictionary*)[result valueForKey:@"header"];
        header = headerDic;
        [self byoga];
         [self setupViewControllers];
         [self changeSegmentedControlValue];
    }];
}


-(void)byoga{
    self.profilename.text = [header objectForKey:@"username"];
    [self.profilepicture setImageWithURL:[NSURL URLWithString:[header objectForKey:@"profile_img"]]
                        placeholderImage:[UIImage imageNamed:@"default.png"]];
    self.FolloweeNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follower_num"]];
    self.FollowNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"follow_num"]];
    self.CheerNum.text = [NSString stringWithFormat:@"%@",[header objectForKey:@"cheer_num"]];
}

-(void)eventSettingBtn{
    [self performSegueWithIdentifier:@"goSetting" sender:self];
}

-(void)eventUserAddBtn{
    [self performSegueWithIdentifier:@"goUserAdd" sender:self];
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