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
@property (nonatomic, copy) NSMutableArray *postid_;
@property (nonatomic, copy) NSMutableArray *locality_;
@property (nonatomic, copy) NSMutableArray *starnum_;
@property (nonatomic, copy) Sample5TableViewCell *cell;
@property (nonatomic, copy) NSMutableArray *commentnum_;
@property (nonatomic, retain) NSIndexPath *nowindexPath;
@property (weak, nonatomic) IBOutlet UIImageView *profilepicture;
@property (weak, nonatomic) IBOutlet UILabel *profilename;
@property (nonatomic, retain) NSIndexPath *nowindexPath1;
@property (nonatomic, retain) NSIndexPath *nowindexPath2;


@end

@implementation usersTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UIImageを指定した生成例
    UIImage *image = [UIImage imageNamed:@"gocci-moji.png"];
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = myImageView;
    
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
    AppDelegate* profiledelegate = [[UIApplication sharedApplication] delegate];
    self.profilename.text = profiledelegate.username;
    [self.profilepicture setImageWithURL:[NSURL URLWithString:profiledelegate.userpicture]
                       placeholderImage:[UIImage imageNamed:@"default.png"]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
    //JSONをパース
    AppDelegate* profiledelegate = [[UIApplication sharedApplication] delegate];
    NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/mypage/?user_name=%@",profiledelegate.username];
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
    
    /*
    AppDelegate* logindelegate2 = [[UIApplication sharedApplication] delegate];
    
    //JSONをパース
    NSString *urlString2 = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/review/?user_name=%@",logindelegate2.username];
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
    */
    
    [self updateVisibleCells];
    [SVProgressHUD dismiss];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
    [moviePlayer stop];
    [moviePlayer.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    
    //投稿が0の時の画面表示
    if([_movie_ count] == 0){
        
        NSLog(@"投稿がありません。");
        
        // UIImageViewの初期化
        CGRect rect = CGRectMake(30, 150, 250, 285);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        
        // 画像の読み込み
        imageView.image = [UIImage imageNamed:@"lion huki iro.png"];
        
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView];
    }
    // Return the number of rows in the section.
    return [_movie_ count];
}

- (void)endScroll {
    //スクロール終了
    //スクロール終了
    CGPoint offset =  self.tableView.contentOffset;
    CGPoint p = CGPointMake(183.0, 200.0 + offset.y);
    _nowindexPath2 = [self.tableView indexPathForRowAtPoint:p];
    NSLog(@"p:%ld", (long)_nowindexPath2.row);
    [self updateVisibleCells];
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
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // フリック操作によるスクロール終了
    [self endScroll];
     [moviePlayer play];
    NSLog(@"scroll is stoped");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        // ドラッグ終了 かつ 加速無し
       // [self endScroll];
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
    return  483.0;
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

//////////////////////////Goodボタンの時の処理//////////////////////////

- (void)handleTouchButton2:(UIButton *)sender event:(UIEvent *)event {
    //このSegueに付けたIdentifierから遷移を呼び出すことができます
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postID = [_postid_ objectAtIndex:indexPath.row];
    NSLog(@"postid:%@",_postID);
    NSString *content = [NSString stringWithFormat:@"post_id=%@",_postID];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/goodinsert/"];
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
        AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
        NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/mypage/?user_name=%@",logindelegate.username];
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

- (void)updateVisibleCells {
    //画面上に見えているセルの表示更新
    for (_cell in [self.tableView visibleCells]){
        [self updateCell:_cell atIndexPath:[self.tableView indexPathForCell:_cell]];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    NSString *cellIdentifier = @"usersTableViewCell";
    _cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!_cell){
        _cell = [[Sample5TableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *buttontext2 = [_restname_ objectAtIndex:indexPath.row];
    [_cell.RestnameButton setTitle:buttontext2 forState:UIControlStateNormal];
    //restaurant nameタップのイベント
    [_cell.RestnameButton addTarget:self action:@selector(handleTouchButton4:event:) forControlEvents:UIControlEventTouchUpInside];
    
    /*
     //動画サムネイル画像の表示
     NSString *dottext2 = [_thumbnail_ objectAtIndex:indexPath.row];
     // Here we use the new provided setImageWithURL: method to load the web image
     [_cell.thumbnailView  setImageWithURL:[NSURL URLWithString:dottext2]
     placeholderImage:[UIImage imageNamed:@"yomikomi simple.png"]];
     */
    
    //ユーザーの画像を取得
    NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
    // Here we use the new provided setImageWithURL: method to load the web image
    [_cell.UsersPicture setImageWithURL:[NSURL URLWithString:dottext]
                       placeholderImage:[UIImage imageNamed:@"default.png"]];
    
    
    //セルの更新メソッド
    [self updateCell:_cell atIndexPath:indexPath];
    return _cell ;
}


- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    //updateした時の処理
    
    NSString *startext = [_starnum_ objectAtIndex:indexPath.row];
    // 文字列をNSIntegerに変換
    NSInteger inted = startext.integerValue;
    NSLog(@"文字列→NSInteger:%ld", inted);
    
    switch(inted){
        case 1:
        {
            UIImage *image = [UIImage imageNamed:@"star_green1.png"];
            _cell.starImage.image = image;
            break;
        }
            
        case 2:
        {
            UIImage *image = [UIImage imageNamed:@"star_green2.png"];
            _cell.starImage.image = image;
            break;
        }
        case 3:
        {
            UIImage *image = [UIImage imageNamed:@"star_green3.png"];
            _cell.starImage.image = image;
            break;
        }
        case 4:
        {
            UIImage *image = [UIImage imageNamed:@"star_green4.png"];
            _cell.starImage.image = image;
            break;
        }
        case 5:
        {
            UIImage *image = [UIImage imageNamed:@"star_green5.png"];
            _cell.starImage.image = image;
            break;
        }
        default:
        {
            UIImage *image = [UIImage imageNamed:@"star_green5.png"];
            _cell.starImage.image = image;
            break;
        }
    }
    
    _cell.UsersName.text = [_user_name_ objectAtIndex:indexPath.row];
    _cell.RestaurantName.text = [_restname_ objectAtIndex:indexPath.row];
    //_cell.Review.text = [_review_ objectAtIndex:indexPath.row];
    _cell.Goodnum.text= [_goodnum_ objectAtIndex:indexPath.row];
    _cell.Commentnum.text = [_commentnum_ objectAtIndex:indexPath.row];
    
    //コメントボタンのイベント
    [_cell.commentBtn addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //いいねボタンのイベント
    [_cell.goodBtn addTarget:self action:@selector(handleTouchButton2:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //削除ボタンのイベント
    [_cell.deleteBtn addTarget:self action:@selector(handleTouchButton3:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //動画再生
    NSString *text = [_movie_ objectAtIndex:indexPath.row];
    NSURL *url = [NSURL URLWithString:text];
    
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    //[moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    CGRect frame = CGRectMake(0, 34, 320, 320);
    
    [moviePlayer.view setFrame:frame];
    //[moviePlayer.view setFrame:_cell.movieView.frame];
    [_cell.contentView addSubview: moviePlayer.view];
    [_cell.contentView bringSubviewToFront:moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    
    [moviePlayer setShouldAutoplay:YES];
    [moviePlayer prepareToPlay];
}

-(void)movieLoadStateDidChange:(id)sender{
    if(MPMovieLoadStatePlaythroughOK ) {
        NSLog(@"STATE CHANGED");
        //動画サムネイル画像のhidden
        dispatch_async(dispatch_get_main_queue(), ^{
            //_cell.thumbnailView.hidden = YES;
        });
    }
}


 - (void)handleTouchButton3:(UIButton *)sender event:(UIEvent *)event {
     Class class = NSClassFromString(@"UIAlertController");
     if(class){
         // iOS 8の時の処理
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お知らせ" message:@"投稿を削除してもいいですか？" preferredStyle:UIAlertControllerStyleAlert];
     
     // addActionした順に左から右にボタンが配置されます
     [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         
         //削除ボタンの時の処理
         NSIndexPath *indexPath = [self indexPathForControlEvent:event];
         NSLog(@"row %ld was tapped.",(long)indexPath.row);
         _postID = [_postid_ objectAtIndex:indexPath.row];
         NSLog(@"postid:%@",_postID);
         NSString *content = [NSString stringWithFormat:@"post_id=%@",_postID];
         NSLog(@"content:%@",content);
         NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/delete/"];
         NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
         [urlRequest setHTTPMethod:@"POST"];
         [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
         NSURLResponse* response;
         NSError* error = nil;
         NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                returningResponse:&response
                                                            error:&error];
         dispatch_queue_t q1_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
         dispatch_queue_t q1_main = dispatch_get_main_queue();
         dispatch_async(q1_global, ^{
             
             //JSONをパース(test)
             AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
             NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/mypage/?user_name=%@",logindelegate.username];
             NSLog(@"restpage:%@",urlString);
             NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
             NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
             NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
             NSError *error=nil;
             NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:NSJSONReadingMutableLeaves error:&error];
             
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
             
             //AppDelegate* logindelegate2 = [[UIApplication sharedApplication] delegate];
             /*
             //JSONをパース
             NSString *urlString2 = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/review/?user_name=%@",logindelegate2.username];
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
             */
             dispatch_async(q1_main, ^{
                 [self.tableView reloadData];
             });
         });
         
         
         
         NSLog(@"goodBtn is touched");
         
     }]];
     [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         
     }]];
     
     [self presentViewController:alertController animated:YES completion:nil];
     }else{
                                             //削除ボタンの時の処理
                                    NSIndexPath *indexPath = [self indexPathForControlEvent:indexPath];
                                    NSLog(@"row %ld was tapped.",(long)indexPath.row);
                                    _postID = [_postid_ objectAtIndex:indexPath.row];
                                    NSLog(@"postid:%@",_postID);
                                    NSString *content = [NSString stringWithFormat:@"post_id=%@",_postID];
                                    NSLog(@"content:%@",content);
                                    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/delete/"];
                                    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                                    [urlRequest setHTTPMethod:@"POST"];
                                    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
                                    NSURLResponse* response;
                                    NSError* error = nil;
                                    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                                           returningResponse:&response
                                                                                       error:&error];
                                    dispatch_queue_t q1_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                                    dispatch_queue_t q1_main = dispatch_get_main_queue();
                                    dispatch_async(q1_global, ^{
                                        
                                        ///JSONをパース
                                        AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
                                        NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/mypage/?user_name=%@",logindelegate.username];
                                        NSLog(@"restpage:%@",urlString);
                                        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
                                        NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                                        NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
                                        NSError *error=nil;
                                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                                                options:NSJSONReadingMutableLeaves error:&error];
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
                                        /*
                                        AppDelegate* logindelegate2 = [[UIApplication sharedApplication] delegate];
                                        
                                        //JSONをパース
                                        NSString *urlString2 = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/review/?user_name=%@",logindelegate2.username];
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
                                        */
                                        dispatch_async(q1_main, ^{
                                            [self.tableView reloadData];
                                        });
                                    });
         
     }
    
 }


//restnameをタップした時のイベント
- (void)handleTouchButton4:(UIButton *)sender event:(UIEvent *)event {
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSLog(@"row %ld was tapped.",(long)indexPath.row);
    _postRestname = [_restname_ objectAtIndex:indexPath.row];
    NSLog(@"postrestname:%@",_postRestname);
    [self performSegueWithIdentifier:@"goRestpage" sender:self];
    NSLog(@"Restname is touched");
    
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
    //店舗画面にパラメータを渡して遷移する
    if ([segue.identifier isEqualToString:@"goRestpage"]) {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
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
