//
//  UserSearchController.m
//  Gocci
//
//  Created by Castela on 2015/10/07.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "UserSearchController.h"
#import "UserSearchTableViewCell.h"
#import "Swift.h"

static NSString * const reuseIdentifier = @"Cell";

@interface UserSearchController ()<UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation UserSearchController
{
    NSMutableArray *thumb;
    NSMutableArray *postid_;
    NSMutableArray *restname;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.bounces = NO;
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.tintColor = [UIColor darkGrayColor];
    _searchBar.placeholder = @"検索";
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;
    self.navigationItem.titleView = _searchBar;
    self.navigationItem.titleView.frame = CGRectMake(0, 0, 320, 44);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    _searchBar.text = nil;
    
    __weak typeof(self)weakSelf = self;
   
    //API
    /*
   [[LocationClient sharedClient] requestLocationWithCompletion:^(CLLocation *location, NSError *error) {
        if (error) {
            LOG(@"位置情報の取得に失敗 / error=%@", error);
            return;
        }
        
        weakSelf.fetchedLocation = location;
        
        // 画面を表示した初回の一回のみ、現在地を中心にしたレストラン一覧を取得する
        static dispatch_once_t searchCurrentLocationOnceToken;
        dispatch_once(&searchCurrentLocationOnceToken, ^{
            [weakSelf _fetchFirstRestaurantsWithCoordinate:location.coordinate];
        });
    }];
     */
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    [self _searchUser:searchBar.text];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [postid_ count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  レストランを検索
 *
 *  @param searchText 検索文字列
 */
- (void)_searchUser:(NSString *)searchText
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    __weak typeof(self)weakSelf = self;
    
    
    //search API
    /*
    [APIClient User:Persistent.user_id handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        else{
            NSLog(@"users result:%@",result);
            
            // 取得したデータを self.posts に格納
            thumb = [NSMutableArray arrayWithCapacity:0];
            postid_ = [NSMutableArray arrayWithCapacity:0];
            restname = [NSMutableArray arrayWithCapacity:0];
            
            NSArray* items = (NSArray*)[result valueForKey:@"posts"];
            
            for (NSDictionary *post in items) {
                
                NSDictionary *thumbGet = [post objectForKey:@"thumbnail"];
                [thumb addObject:thumbGet];
                NSDictionary *postidGet = [post objectForKey:@"post_id"];
                [postid_ addObject:postidGet];
                NSDictionary *restnameGet = [post objectForKey:@"restname"];
                [restname addObject:restnameGet];
            }
            NSLog(@"thumb:%@,id:%@,restname:%@",thumb,postid_,restname);
            [self.tableView reloadData];
        }
    }];
     */
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
