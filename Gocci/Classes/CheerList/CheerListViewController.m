//
//  CheerListViewController.m
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "CheerListViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "RestaurantTableViewController.h"
#import "APIClient.h"

@interface CheerListViewController ()


@property (nonatomic, retain) NSMutableArray *locality_;
@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *rest_id_;
@property (nonatomic, retain) CheerListCell *cell;


@end



@implementation CheerListViewController

static NSString * const SEGUE_GO_RESTAURANT = @"goRestpage";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //ナビゲーションバーに画像
    {
        self.title = @"応援";
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    
    // !!!:dezamisystem
    //	self.navigationItem.title = @"コメント画面";
    
    UINib *nib = [UINib nibWithNibName:@"CheerListCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"CheerListCell"];
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    
    _postRestID =  [_rest_id_ objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:SEGUE_GO_RESTAURANT sender:self];
    
}

#pragma mark - Json
-(void)perseJson
{
    //test user
    //_postIDtext = @"3024";
    [APIClient CheerList:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] handler:^(id result, NSUInteger code, NSError *error) {
                
        LOG(@"resultComment=%@", result);
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            
            // TODO: アラート等を掲出
            return;
        }
        
        if(result){
           
            //住所
            NSArray *locality = [result valueForKey:@"locality"];
            _locality_ = [locality mutableCopy];
            //店名
            NSArray *restname = [result valueForKey:@"restname"];
            _restname_ = [restname mutableCopy];
            //店舗ID
            NSArray *rest_id = [result valueForKey:@"rest_id"];
            _rest_id_ = [rest_id mutableCopy];
            
            if([_locality_ count] ==0){
                // 画像表示例文
                UIImage *img = [UIImage imageNamed:@"sad_cheer.png"];
                UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                CGSize boundsSize = self.view.bounds.size;
                iv.center = CGPointMake( boundsSize.width / 2, boundsSize.height / 2 );
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestID;
    }
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
    return [_restname_ count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _cell = (CheerListCell *)[tableView dequeueReusableCellWithIdentifier:@"CheerListCell"];
    
    _cell.RestName.text = [_restname_ objectAtIndex:indexPath.row];
    _cell.Locality.text = [_locality_ objectAtIndex:indexPath.row];
    [SVProgressHUD dismiss];
    
    return _cell;
}



@end
