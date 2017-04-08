//
//  FollowListViewController.m
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "FollowListViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "UserpageViewController.h"
#import "APIClient.h"
#import "Swift.h"

@interface FollowListViewController ()<FollowListCellDelegate>


@property (nonatomic, retain) NSMutableArray *post;
@property (nonatomic, retain) NSMutableArray *userid;


@end

static NSString * const SEGUE_GO_PROFILE = @"goProfile";


@implementation FollowListViewController

@synthesize userID = _userID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        self.title = @"フォロー";
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    UINib *nib = [UINib nibWithNibName:@"FollowListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FollowListCell"];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
}


-(void)perseJson
{
    [APIClient Follow:_userID handler:^(id result, NSUInteger code, NSError *error) {
     
        LOG(@"resultComment=%@", result);
        
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
                    // 画像表示例文
                    UIImage *img = [UIImage imageNamed:@"sad_follow.png"];
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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [SVProgressHUD dismiss];
    [self perseJson];
    
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}



-(void)follow:(FollowListCell *)cell didTapUsername:(NSString *)user_id{
    [self performSegueWithIdentifier:SEGUE_GO_PROFILE sender:user_id];
}

-(void)follow:(FollowListCell *)cell didTapProfile_img:(NSString *)user_id{
    [self performSegueWithIdentifier:SEGUE_GO_PROFILE sender:user_id];
}

-(void)follow:(FollowListCell *)cell didTapLikeButton:(NSString *)userID tapped:(BOOL)tapped{
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.8];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:SEGUE_GO_PROFILE])
    {
        //ここでパラメータを渡す
        UserpageViewController *userVC = segue.destinationViewController;
        userVC.postUsername = sender;
    }
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FollowListCell";
    FollowListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[FollowListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    Follow *post = self.post[indexPath.row];
    NSLog(@"count:%@",post);
    [cell configureWithFollow:post indexPath:indexPath.row];
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
