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
#import "usersTableViewController_other.h"
#import "APIClient.h"

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
    
    
    //ナビゲーションバーに画像
    {
        //CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    // !!!:dezamisystem
    //	self.navigationItem.title = @"コメント画面";
    
    UINib *nib = [UINib nibWithNibName:@"FollowListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FollowListCell"];
    
    //背景にイメージを追加したい
    // UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    // self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    // !!!:dezamisystem
    //	self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    
#if 0
    // タブの中身（UIViewController）をインスタンス化
    UIViewController *item01 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    UIViewController *item02 = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    NSArray *views = [NSArray arrayWithObjects:item01,item02, nil];
    
    // タブコントローラをインスタンス化
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.delegate = self;
    
    // タブコントローラにタブの中身をセット
    [tbc setViewControllers:views animated:NO];
    [self.view addSubview:tbc.view];
    
    // １つめのタブのタイトルを"hoge"に設定する
    UITabBarItem *tbi = [tbc.tabBar.items objectAtIndex:0];
    tbi.title = @"hoge";
    tbi = [tbc.tabBar.items objectAtIndex:1];
    tbi.title = @"ABCDEFG";
#endif
    
    
}


-(void)perseJson
{
    //test user
    [APIClient FollowList:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        LOG(@"resultComment=%@", result);
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            
            // TODO: アラート等を掲出
            return;
        }
        
        if(result){
            
            // ユーザー名
            NSArray *user_name = [result valueForKey:@"username"];
            _user_name_ = [user_name mutableCopy];
            NSLog(@"user_name:%@",_user_name_);
            // プロフ画像
            NSArray *picture = [result valueForKey:@"profile_img"];
            _picture_ = [picture mutableCopy];
            // フォローしてるか
            NSArray *follow_flag = [result valueForKey:@"follow_flag"];
            _follow_flag_ = [follow_flag mutableCopy];
            // User_id
            NSArray *user_id = [result valueForKey:@"user_id"];
            _user_id_ = [user_id mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    
    _postUsername_with_profile =  [_user_id_ objectAtIndex:indexPath.row];
    _postUserPicture_with_profile = [_picture_ objectAtIndex:indexPath.row];
    _postUserFlag_with_profile = [_follow_flag_ objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_GO_PROFILE sender:self];

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   if ([segue.identifier isEqualToString:SEGUE_GO_PROFILE])
    {
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
        //ユーザーの画像を取得
        NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
        // Here we use the new provided setImageWithURL: method to load the web image
        [_cell.UsersPicture setImageWithURL:[NSURL URLWithString:dottext]
                           placeholderImage:[UIImage imageNamed:@"default.png"]];
    }
    
    [SVProgressHUD dismiss];
    
    return _cell;
}

@end
