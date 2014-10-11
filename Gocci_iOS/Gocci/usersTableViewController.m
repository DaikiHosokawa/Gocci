//
//  usersTableViewController.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "usersTableViewController.h"
#import "Sample5TableViewCell.h"
#import "SVProgressHUD.h"
#import "everyTableViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface usersTableViewController ()

@property (nonatomic, retain) NSMutableArray *restname_;
@property (nonatomic, retain) NSMutableArray *goodnum_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, copy) NSMutableArray *picture_;
@property (nonatomic, copy) NSMutableArray *movie_;
@property (nonatomic, copy) NSMutableArray *review_;
@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSMutableArray *locality_;
@property (nonatomic, copy) Sample5TableViewCell *cell;
@property (nonatomic, copy) NSMutableArray *commentnum_;
@property (nonatomic, retain) NSIndexPath *nowindexPath;

@end

@implementation usersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //カスタムセルの導入
    UINib *nib = [UINib nibWithNibName:@"Sample5TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"usersTableViewCell"];
    
    //背景にイメージを追加したい
    //UIImage *backgroundImage = [UIImage imageNamed:@"login.png"];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    self.tableView.separatorColor = [UIColor clearColor ];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
    
    //JSONをパース
    NSString *urlString = [NSString stringWithFormat:@"https://codelecture.com/gocci/mypage.php"];
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
        
        dispatch_async(q_main, ^{
        });
    });
    
    AppDelegate* logindelegate2 = [[UIApplication sharedApplication] delegate];
    
    //JSONをパース
    NSString *urlString2 = [NSString stringWithFormat:@"https://codelecture.com/gocci/submit/user_review.php?user_name=%@",logindelegate2.username];
    NSLog(@"restpage:%@",urlString2);
    NSURL *url2 = [NSURL URLWithString:[urlString2 stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSString *response2 = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData2 = [response2 dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error2=nil;
    NSDictionary *jsonDic2 = [NSJSONSerialization JSONObjectWithData:jsonData2
                                                            options:NSJSONReadingMutableLeaves error:&error2];
    NSLog(@"jsonDic:%@", jsonDic2);
    //レビュー
    NSArray *review = [jsonDic2 valueForKey:@"review"];
    _review_ = [review mutableCopy];
    
    
    [self updateVisibleCells];
    [SVProgressHUD dismiss];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
    [moviePlayer stop];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    /*
    //投稿が0の時の画面表示
    if([_movie_ count] == 0){
        
        NSLog(@"投稿がありません。");
        
        // UIImageViewの初期化
        CGRect rect = CGRectMake(30, 150, 250, 250);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        
        // 画像の読み込み
        imageView.image = [UIImage imageNamed:@"lion huki iro.png"];
        
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView];
        
    }
     */
    
    // Return the number of rows in the section.
    return [_movie_ count];
}

- (void)endScroll {
    //スクロール終了
    CGPoint offset =  self.tableView.contentOffset;
    CGPoint p = CGPointMake(183.0, 284.0 + offset.y);
    _nowindexPath = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"%ld", (long)_nowindexPath.row);
    [self updateVisibleCells];
    //_thumbnailView.hidden = YES;
    [moviePlayer play];
}

//////////////////////////スクロール開始後//////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 表示しているtableVIewの現状のオフセットを取得する。
    // ・tableVIewのオフセットはスクロールさせると値が変わるよ。
    CGPoint offset =  self.tableView.contentOffset;
    
    // オフセットの位置からy軸に120ポイント下に座標を指定してみよう。
    // ・この場合だと、見た目上(画面上)の(10, 120)の位置を常にCGPointで取得してるってこと。
    CGPoint p = CGPointMake(183.0, 284.0 + offset.y);
    
    // で、オフセット分を調整した座標(p)からindexPathが取得できるようになると。
    _nowindexPath = [self.tableView indexPathForRowAtPoint:p];
    
    NSLog(@"%ld", (long)_nowindexPath.row);
    
    [moviePlayer stop];
    //一番下までスクロールしたかどうか
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height))
    {
        //ここで次に表示する件数を取得して表示更新の処理を書けばOK
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // フリック操作によるスクロール終了
    [self endScroll];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        // ドラッグ終了 かつ 加速無し
        [self endScroll];
        NSLog(@"scroll is stoped");
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
    return 520.0;
}

//////////////////////////コメントボタンの時の処理//////////////////////////

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"移動中.." maskType:SVProgressHUDMaskTypeGradient];
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    
    [self performSegueWithIdentifier:@"showDetail2" sender:self];
    NSLog(@"commentBtn is touched");
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
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
    NSURL* url = [NSURL URLWithString:@"https://codelecture.com/gocci/goodinsert.php"];
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
        NSString *urlString = [NSString stringWithFormat:@"https://codelecture.com/gocci/submit/restpage.php?restname=%@",_postRestName];
        NSLog(@"restpage:%@",urlString);
        NSURL *url2 = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSString *response2 = [NSString stringWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData2 = [response2 dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error2 =nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData2
                                                                options:NSJSONReadingMutableLeaves error:&error2];
        NSLog(@"jsonDic:%@", jsonDic);
        
        //いいね数
        NSArray *goodnum = [jsonDic valueForKey:@"goodnum"];
        _goodnum_ = [goodnum mutableCopy];
        dispatch_async(q_main, ^{
            [self.tableView reloadData];
            NSLog(@"goodBtn is touched");
        });
    });
    
}

// 画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    for (UITableViewCell *cell in [self.tableView visibleCells]){
        [self updateCell:_cell atIndexPath:[self.tableView indexPathForCell:_cell]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Do any additional setup after loading the view, typically from a nib.
    //storyboardで指定したIdentifierを指定する
    
    NSString *cellIdentifier = @"usersTableViewCell";
    _cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!_cell){
        _cell = [[Sample5TableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    // セルの更新
    [self updateCell:_cell atIndexPath:indexPath];
    // Configure the cell...
    
    // Configure the cell...
    return _cell;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //updateした時の処理
    _cell.UsersName.text = [_user_name_ objectAtIndex:indexPath.row];
    _cell.RestaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    _cell.Review.text = [_review_ objectAtIndex:indexPath.row];
    _cell.Goodnum.text= [_goodnum_ objectAtIndex:indexPath.row];
    _cell.Commentnum.text = [_commentnum_ objectAtIndex:indexPath.row];
    
    
    //コメントボタンのイベント
    [_cell.commentBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //いいねボタンのイベント
    [_cell.goodBtn addTarget:self action:@selector(handleTouchButton2:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //ユーザーの画像を取得
    NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
    // Here we use the new provided setImageWithURL: method to load the web image
    [_cell.UsersPicture setImageWithURL:[NSURL URLWithString:dottext]
                       placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    //動画再生
    NSString *text = [_movie_ objectAtIndex:_nowindexPath.row];
    NSURL *url = [NSURL URLWithString:text];
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    [moviePlayer.view setFrame:_cell.movieView.frame];
    [_cell.movieView addSubview: moviePlayer.view];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer prepareToPlay];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    [moviePlayer play];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //2つ目の画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"showDetail2"]) {
        //ここでパラメータを渡す
        everyTableViewController *eveVC = segue.destinationViewController;
        eveVC.postID = _postID;
    }
    
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
