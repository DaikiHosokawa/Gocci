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

@interface FollowListViewController ()


@property (nonatomic, retain) NSMutableArray *picture_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, retain) FollowListCell *cell;


@end



@implementation FollowListViewController

@synthesize postUsername = _postUsername;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //ナビゲーションバーに画像
    {
        //タイトル画像設定
        //CGFloat width_image = height_image;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
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
    
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [SVProgressHUD show];
    [super viewWillAppear:animated];
    
    // !!!:dezamisystem
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    [SVProgressHUD dismiss];
    
    //JSONをパース
    NSString *timelineString = [NSString stringWithFormat:@"http://api-gocci.jp/favorites_list/?user_name=%@&get=follower",_postUsername];
    NSString* escaped = [timelineString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* Url = [NSURL URLWithString:escaped];
    NSString *response = [NSString stringWithContentsOfURL:Url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"response:%@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSLog(@"jsonData:%@",jsonData);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSLog(@"jsonDic:%@",jsonDic);
    
    // ユーザー名
    NSArray *user_name = [jsonDic valueForKey:@"user_name"];
    _user_name_ = [user_name mutableCopy];
    NSLog(@"user_name:%@",_user_name_);
    // プロフ画像
    NSArray *picture = [jsonDic valueForKey:@"picture"];
    _picture_ = [picture mutableCopy];
    
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
