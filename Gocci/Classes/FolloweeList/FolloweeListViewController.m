//
//  FolloweeListViewController.m
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "FolloweeListViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "UserpageViewController.h"
#import "APIClient.h"
#import "Swift.h"


@interface FolloweeListViewController ()<FolloweeListCellDelegate>

@property (nonatomic, retain) NSMutableArray *post;
@property (nonatomic, retain) NSMutableArray *userid;


@end

static NSString * const SEGUE_GO_PROFILE = @"goProfile";


@implementation FolloweeListViewController

@synthesize userID = _userID;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    {
        self.title = @"フォロワー";
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    UINib *nib = [UINib nibWithNibName:@"FolloweeListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FolloweeListCell"];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
#if 0
    UIViewController *item01 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    UIViewController *item02 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    NSArray *views = [NSArray arrayWithObjects:item01,item02, nil];
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.delegate = self;
    
    [tbc setViewControllers:views animated:NO];
    [self.view addSubview:tbc.view];
    
    UITabBarItem *tbi = [tbc.tabBar.items objectAtIndex:0];
    tbi.title = @"hoge";
    tbi = [tbc.tabBar.items objectAtIndex:1];
    tbi.title = @"ABCDEFG";
#endif
    

}

-(void)perseJson
{
    [APIClient Follower:_userID handler:^(id result, NSUInteger code, NSError *error) {
        
      if (code != 200 || error != nil) {
            return;
        }
        
        if(result){
            
        
            NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
            NSArray* items = (NSArray*)[result valueForKeyPath:@"payload.users"];
            
            for (NSDictionary *post in items) {
                [tempPosts addObject:[Follow timelinePostWithDictionary:post]];
            }
            
             NSLog(@"items2:%@",tempPosts);
            
            self.post = tempPosts;
            
            if([self.post count] ==0){
               UIImage *img = [UIImage imageNamed:@"sad_follower.png"];
                UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                CGSize boundsSize = self.view.bounds.size;
                iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2-50 );
                [self.view addSubview:iv];
                self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    [SVProgressHUD show];
    [super viewWillAppear:animated];
    
    // !!!:dezamisystem
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    [SVProgressHUD dismiss];
    
    [self perseJson];
    
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}



-(void)follow:(FolloweeListCell *)cell didTapUsername:(NSString *)user_id{
    [self performSegueWithIdentifier:SEGUE_GO_PROFILE sender:user_id];
}

-(void)follow:(FolloweeListCell *)cell didTapProfile_img:(NSString *)user_id{
    [self performSegueWithIdentifier:SEGUE_GO_PROFILE sender:user_id];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_PROFILE])
    {
        UserpageViewController *userVC = segue.destinationViewController;
        userVC.postUsername = sender;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.8];
}


#pragma mark - Table view data source


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.post count];;
}

-(void)follow:(FolloweeListCell *)cell didTapLikeButton:(NSString *)userID tapped:(BOOL)tapped{
  
    if (tapped) {
        NSLog(@"フォロー");
        [APIClient postFollow:userID handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
            if ([result[@"code"] integerValue] == 200) {
               
            }
        }
         ];
        
    }else {
        NSLog(@"解除");
        [APIClient postUnFollow:userID handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
            if ((code=200)) {
               
            }
        }
         ];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FolloweeListCell";
    FolloweeListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[FolloweeListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    Follow *post = self.post[indexPath.row];
    NSLog(@"count:%@",post);
    [cell configureWithFollow:post indexPath:indexPath.row];
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



@end
