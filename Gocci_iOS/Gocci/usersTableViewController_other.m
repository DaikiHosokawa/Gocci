//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController_other.h"
#import "Sample5TableViewCell_other.h"
#import "SVProgressHUD.h"
#import "everyTableViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking/AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import "Profile_otherPost.h"
#import "MoviePlayerManager.h"
#import "QuartzCore/QuartzCore.h"

@protocol MovieViewDelegate;


@interface usersTableViewController_other ()<Sample5TableViewCell_otherDelegate>

@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *goodnum_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, copy) NSMutableArray *picture_;
@property (nonatomic, copy) NSMutableArray *movie_;
@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSMutableArray *locality_;
@property (nonatomic, copy) NSMutableArray *starnum_;
@property (nonatomic, copy) Sample5TableViewCell_other *cell;
@property (nonatomic, copy) NSMutableArray *commentnum_;
@property (nonatomic, retain) NSIndexPath *nowindexPath;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;
@property (nonatomic, retain) NSIndexPath *nowindexPath1;
@property (nonatomic, retain) NSIndexPath *nowindexPath2;

/** タイムラインのデータ */
@property (nonatomic,strong) NSArray *posts;

@end

@implementation usersTableViewController_other

@synthesize postUsername= _postUsername;
@synthesize postPicture= _postPicture;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = _postUsername;
    
    //カスタムセルの導入
    UINib *nib = [UINib nibWithNibName:@"Sample5TableViewCell_other" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"usersTableViewCell_other"];
    
    self.tableView.allowsSelection = NO;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    self.tableView.separatorColor = [UIColor clearColor ];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    
    AppDelegate* profiledelegate = [[UIApplication sharedApplication] delegate];
    NSString *picturestring = _postPicture;
    self.profilename.text = _postUsername;
    [self.profilepicture setImageWithURL:[NSURL URLWithString:picturestring]
                        placeholderImage:[UIImage imageNamed:@"default.png"]];
   
    // API からタイムラインのデータを取得
    [self _fetchProfile_other];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    
    /*
    NSString *tapusername = _postUsername;
        NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/mypage/?user_name=%@",tapusername];
        NSLog(@"restpage:%@",urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error=nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableLeaves error:&error];
        
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        dispatch_async(q_global, ^{
            // ユーザー名
            NSArray *user_name = [jsonDic valueForKey:@"user_name"];
            _user_name_ = [user_name mutableCopy];
            // プロフ画像
            NSArray *picture = [jsonDic valueForKey:@"picture"];
            _picture_ = [picture mutableCopy];
            // 動画URL
            NSArray *movie = [jsonDic valueForKey:@"movie"];
            _movie_ = [movie mutableCopy];
            // 住所
            NSArray *locality = [jsonDic valueForKey:@"locality"];
            _locality_ = [locality mutableCopy];
            
            //いいね数
            NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
            _goodnum_ = [goodnum mutableCopy];
            
            //レストラン名
            NSArray *restname = [jsonDic valueForKey:@"restname"];
            _restname_ = [restname mutableCopy];
            //画像URL
            NSArray *pictureurl = [jsonDic valueForKey:@"picture"];
            _picture_ = [pictureurl mutableCopy];
            // 動画post_id
            NSArray *postid = [jsonDic valueForKey:@"post_id"];
            _postid_ = [postid mutableCopy];
            //コメント数
            NSArray *commentnum = [jsonDic valueForKey:@"comment_num"];
            _commentnum_ = [commentnum mutableCopy];
            //スターの数
            NSArray *starnum = [jsonDic valueForKey:@"star_evaluation"];
            _starnum_ = [starnum mutableCopy];
            NSLog(@"commentnum:%@",starnum);
            
            dispatch_async(q_main, ^{
            });
        });
    */
    [self _fetchProfile_other];
    [self.tableView reloadData];

    [SVProgressHUD dismiss];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // 画面が隠れた際に再生中の動画を停止させる
    [[MoviePlayerManager sharedManager] stopMovie];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
return [self.posts count];

}

- (void)endScroll {
    //スクロール終了
    CGPoint offset =  self.tableView.contentOffset;
    CGPoint p = CGPointMake(183.0, 200.0 + offset.y);
    _nowindexPath2 = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"p:%ld", (long)_nowindexPath2.row);
   // [self updateVisibleCells];
    if(_nowindexPath1.row != _nowindexPath2.row){
        NSLog(@"現在oが%@でpが%@で前回スクロール時と異なっている",_nowindexPath1,_nowindexPath2);
    }
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

//////////////////////////スクロール開始後//////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // スクロール開始
    CGPoint offset =  self.tableView.contentOffset;
    //スクロールポイントo
    CGPoint o = CGPointMake(183.0, 100.0 + offset.y);
    _nowindexPath1 = [self.tableView indexPathForRowAtPoint:o];
    NSLog(@"%ld", (long)_nowindexPath1.row);
    
    //[self updateVisibleCells];
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
        
    }
    // スクロール中は動画を停止する
    [[MoviePlayerManager sharedManager] scrolling:YES];

}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // フリック操作によるスクロール終了
    [self endScroll];
    LOG(@"scroll is stoped");
    [self _playMovieAtCurrentCell];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        LOG(@"scroll is stoped");
        
        [self _playMovieAtCurrentCell];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // setContentOffset: 等によるスクロール終了
    [self endScroll];
    NSLog(@"scroll is stoped");
    
}




//1セルあたりの高さ
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  483.0;
}
/*
//////////////////////////コメントボタンの時の処理//////////////////////////

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"移動中.." maskType:SVProgressHUDMaskTypeGradient];
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    
    [self performSegueWithIdentifier:@"showDetail3" sender:self];
    NSLog(@"commentBtn is touched");
}

//////////////////////////Goodボタンの時の処理//////////////////////////

- (void)handleTouchButton2:(UIButton *)sender event:(UIEvent *)event {
    //このSegueに付けたIdentifierから遷移を呼び出すことができます
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@",_postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/goodinsert/"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                      
                                                       error:&error];
    
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{
        
        //JSONをパース
        NSString *tapusername = _postUsername;
        NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/mypage/?user_name=%@",tapusername];
        NSLog(@"restpage:%@",urlString);
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error=nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableLeaves error:&error];
        
        //いいね数
        NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
        _goodnum_ = [goodnum mutableCopy];
        dispatch_async(q_main, ^{
            [self.tableView reloadData];
            NSLog(@"goodBtn is touched");
        });
    });
    
}
*/
/*
//restnameをタップした時のイベント
- (void)handleTouchButton4:(UIButton *)sender event:(UIEvent *)event {
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postRestname = [_restname_ objectAtIndex:indexPath.row];
    NSLog(@"postrestname:%@",_postRestname);
    [self performSegueWithIdentifier:@"goRestpage" sender:self];
    NSLog(@"Restname is touched");
    
}
*/


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString *cellIdentifier = @"usersTableViewCell_other";
    Sample5TableViewCell_other *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell){
        cell = [[Sample5TableViewCell_other alloc] initWithStyle:UITableViewCellStyleSubtitle
                                           reuseIdentifier:cellIdentifier];
    }
    // セルにデータを反映
    Profile_otherPost *post = self.posts[indexPath.row];
    [cell configureWithProfile_otherPost:post];
    cell.delegate = self;
    
    // 動画の読み込み
    NSLog(@"読み込み完了");
    __weak typeof(self)weakSelf = self;
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:post.movie
                                                         size:cell.thumbnailView.bounds.size
                                                      atIndex:indexPath.row
                                                   completion:^(BOOL success) {
                                                       [weakSelf _playMovieAtCurrentCell];
                                                   }];

    
    return cell ;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    //セグエで画面遷移させる
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail3"]) {
        //ここでパラメータを渡す
        everyTableViewController *eveVC = segue.destinationViewController;
        eveVC.postID = _postID;
    }
    
    //店舗画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"goRestpage"]) {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    
}

#pragma mark - Sample2TableViewCellDelegate


- (void)sample5TableViewCell_other:(Sample5TableViewCell_other *)cell didTapGoodWithPostID:(NSString *)postID
{
    //いいねボタンの時の処理
    LOG(@"postid=%@", postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@", postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/goodinsert/"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                                                       error:&error];
    
    // タイムラインを再読み込み
    [self _fetchProfile_other];
}

- (void)sample5TableViewCell_other:(Sample5TableViewCell_other *)cell didTapRestnameWithrestname:(NSString *)restname
{
    //rest nameタップの時の処理
    LOG(@"restname=%@", restname);
    _postRestname = restname;
    NSLog(@"postRestname:%@",_postRestname);
    NSLog(@"Restname is touched");
    [self performSegueWithIdentifier:@"goRestpage" sender:self];
}


- (void)sample5TableViewCell_other:(Sample5TableViewCell_other *)cell didTapCommentWithPostID:(NSString *)postID
{
    // コメントボタン押下時の処理
    LOG(@"postid=%@", postID);
    _postID = postID;
    [self performSegueWithIdentifier:@"showDetail3" sender:postID];
}


#pragma mark - Private Methods

/**
 *  API からタイムラインのデータを取得
 */
- (void)_fetchProfile_other
{
    __weak typeof(self)weakSelf = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *userName = _postUsername;
    [APIClient profileWithUserName:(NSString *)userName handler:^(id result, NSUInteger code, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //LOG(@"result=%@", result);
        //LOG(@"code=%@, error=%@", @(code), error);
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            // TODO: アラート等を掲出
            return;
        }
        
        // 取得したデータを self.posts に格納
        NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *post in result) {
            [tempPosts addObject:[Profile_otherPost profile_otherPostWithDictionary:post]];
        }
        self.posts = [NSArray arrayWithArray:tempPosts];
        
        // 動画データを一度全て削除
        [[MoviePlayerManager sharedManager] removeAllPlayers];
        
        // 表示の更新
        [weakSelf.tableView reloadData];
    }];
}

/**
 *  現在表示中のセルの動画を再生する
 */
- (void)_playMovieAtCurrentCell
{
    if (self.navigationController.topViewController != self) {
        // 画面がフォアグラウンドのときのみ再生
        return;
    }
    
    Sample5TableViewCell_other *currentCell = [self _currentCell];
    [[MoviePlayerManager sharedManager] scrolling:NO];
    [[MoviePlayerManager sharedManager] playMovieAtIndex:[self _currentIndexPath].row
                                                  inView:self.tableView
                                                   frame:CGRectMake(0,
                                                                    currentCell.frame.size.height * [self _currentIndexPath].row + currentCell.thumbnailView.frame.origin.y+66,
                                                                    currentCell.thumbnailView.frame.size.width,
                                                                    currentCell.thumbnailView.frame.size.height)];
}

/**
 *  現在表示中のセルを取得
 *
 *  @return
 */
- (Sample5TableViewCell_other *)_currentCell
{
    return (Sample5TableViewCell_other *)[self tableView:self.tableView cellForRowAtIndexPath:[self _currentIndexPath]];
}

/**
 *  現在表示中の indexPath を取得
 *
 *  @return
 */
- (NSIndexPath *)_currentIndexPath
{
    CGPoint point = CGPointMake(self.tableView.contentOffset.x,
                                self.tableView.contentOffset.y + self.tableView.frame.size.height/2);
    NSIndexPath *currentIndexPath = [self.tableView indexPathForRowAtPoint:point];
    
    return currentIndexPath;
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
