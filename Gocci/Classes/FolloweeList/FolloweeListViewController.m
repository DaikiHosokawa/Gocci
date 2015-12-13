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


@interface FolloweeListViewController ()

@property (nonatomic, retain) NSMutableArray *picture_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, retain) NSMutableArray *follow_flag_;
@property (nonatomic, retain) NSMutableArray *user_id_;
@property (nonatomic, retain) FolloweeListCell *cell;


@end

static NSString * const SEGUE_GO_PROFILE = @"goProfile";


@implementation FolloweeListViewController

@synthesize postUsername = _postUsername;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    //ナビゲーションバーに画像
    {
        self.title = @"フォロワー";
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    // !!!:dezamisystem
    //	self.navigationItem.title = @"コメント画面";
    
    UINib *nib = [UINib nibWithNibName:@"FolloweeListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"FolloweeListCell"];
    
    //背景にイメージを追加したい
    // UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    // self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
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
    //_postIDtext = @"3024";
    [APIClient FollowerList:Persistent.user_id handler:^(id result, NSUInteger code, NSError *error) {
        
       // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
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
            
            
            
            if([_user_name_ count] ==0){
                // 画像表示例文
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    
    _postUsername_with_profile =  [_user_id_ objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:SEGUE_GO_PROFILE sender:self];

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
    return [_user_name_ count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _cell = (FolloweeListCell*)[tableView dequeueReusableCellWithIdentifier:@"FolloweeListCell"];
    
    
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
