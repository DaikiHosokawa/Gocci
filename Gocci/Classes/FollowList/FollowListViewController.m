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

@interface FollowListViewController ()


@property (nonatomic, retain) NSMutableArray *picture_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, retain) NSMutableArray *follow_flag_;
@property (nonatomic, retain) NSMutableArray *user_id_;
@property (nonatomic, retain) FollowListCell *cell;


@end

static NSString * const SEGUE_GO_PROFILE = @"goProfile";


@implementation FollowListViewController

@synthesize postUsername = _postUsername;

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
    [APIClient FollowList:Persistent.user_id handler:^(id result, NSUInteger code, NSError *error) {
     
        LOG(@"resultComment=%@", result);
        
        if (code != 200 || error != nil) {
            
            return;
        }
        
        if(result){
            
            NSArray *user_name = [result valueForKey:@"username"];
            _user_name_ = [user_name mutableCopy];
           
            NSArray *picture = [result valueForKey:@"profile_img"];
            _picture_ = [picture mutableCopy];
            
            NSArray *follow_flag = [result valueForKey:@"follow_flag"];
            _follow_flag_ = [follow_flag mutableCopy];
           
            NSArray *user_id = [result valueForKey:@"user_id"];
            _user_id_ = [user_id mutableCopy];
            
            if([_user_name_ count] ==0){
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    _postUsername_with_profile =  [_user_id_ objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_GO_PROFILE sender:self];

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
        userVC.postUsername = _postUsername_with_profile;
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
    return [_user_name_ count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _cell = (FollowListCell*)[tableView dequeueReusableCellWithIdentifier:@"FollowListCell"];
    
    
    _cell.UsersName.text = [_user_name_ objectAtIndex:indexPath.row];
    
    if([_picture_ objectAtIndex:indexPath.row] != nil){
        NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
        [_cell.UsersPicture setImageWithURL:[NSURL URLWithString:dottext]
                           placeholderImage:[UIImage imageNamed:@"default.png"]];
    }
    
    [SVProgressHUD dismiss];
    return _cell;
}

@end
