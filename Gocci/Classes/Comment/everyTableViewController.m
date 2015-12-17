//
//  everyTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "everyTableViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "EveryPost.h"
#import "UserpageViewController.h"
#import "RestaurantTableViewController.h"
#import "APIClient.h"


static NSString * const SEGUE_GO_USERS_OTHERS = @"goUsersOthers";
static NSString * const SEGUE_GO_RESTAURANT = @"goRestaurant";

@interface everyTableViewController ()
{
    NSArray *list_comments;
    EveryPost *myPost;
    NSMutableArray *postCommentname;
}

@property (nonatomic, retain) NSMutableArray *picture_;
@property (nonatomic, readwrite) NSMutableArray *comment_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, retain) Sample4TableViewCell *cell;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, retain) NSString *dottext;
@property (nonatomic, retain) NSString *postIDtext;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation everyTableViewController
{
    NSString *_text, *_hashTag;
}
@synthesize postID = _postID;

-(id)initWithText:(NSString *)text hashTag:(NSString *)hashTag
{
    self = [super init];
    if (self) {
        _text = text;
        _hashTag = hashTag;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 描画
#pragma mark viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //ナビゲーションバーに画像
    {
        //タイトル画像設定
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
    }
    
    
    UINib *nib = [UINib nibWithNibName:@"Sample4TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Sample4TableViewCell"];
    
    //背景にイメージを追加したい
    // UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    // self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.delegate = self;
    self.tableView.bounces = YES;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _textField.placeholder = @"ここにコメントを入力してください。";
    _textField.delegate = self;
    
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

#pragma mark viewWillAppear
-(void)viewWillAppear:(BOOL)animated
{
    
    [self perseJson];
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    _postIDtext = _postID;
    NSLog(@"postIDtext:%@",_postIDtext);
    
    // キーボードの表示・非表示がNotificationCenterから通知される
    
}




#pragma mark viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    NSLog(@"Editing");
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
    NSLog(@"End Editing");
}



- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 230; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark - Json
-(void)perseJson
{
    [SVProgressHUD show];
    [APIClient commentJSON:_postID handler:^(id result, NSUInteger code, NSError *error) {
        
        
        LOG(@"resultComment=%@", result);
        
        if (code != 200 || error != nil) {
            // API からのデータの取得に失敗
            
            // TODO: アラート等を掲出
            [SVProgressHUD dismiss];
            return;
        }
        
        if(result){
            NSArray* d_comments = (NSArray*)[result valueForKey:@"comments"];
            NSLog(@"d_comments:%@",d_comments);
            list_comments = [[NSArray alloc] initWithArray:d_comments];
            [SVProgressHUD dismiss];
            
            if ([list_comments count]>0) {
                
                self.listUsername = [[NSMutableArray alloc] init];
                self.listProfileImg = [[NSMutableArray alloc] init];
                self.listComment = [[NSMutableArray alloc] init];
                self.listDate = [[NSMutableArray alloc] init];
                
                
                for (NSDictionary *dict in list_comments) {
                    NSLog(@"list_comments:%@",list_comments);
                    
                    NSString *username = [dict objectForKey:@"username"];
                    [self.listUsername addObject:username];
                    
                    NSString *picture = [dict objectForKey:@"profile_img"];
                    [self.listProfileImg addObject:picture];
                    
                    NSString *comment = [dict objectForKey:@"comment"];
                    [self.listComment addObject:comment];
                    
                    NSString *date_str = [dict objectForKey:@"comment_date"];
                    [self.listDate addObject:date_str];
                }
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }
            
        }
    }];
    
}

#pragma mark - アクション
- (IBAction)pushSendBtn:(id)sender
{
    _dottext = _textField.text;
    NSLog(@"入力:%@",_textField.text);
    
    if (_textField.text.length == 0) {
        //アラート出す
        NSLog(@"textlength:%lu",(unsigned long)_textField.text.length);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"コメントを入力してください"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSLog(@"コメント内容:%@",_dottext);
        NSLog(@"sendBtn is touched");;
        
        [APIClient postComment:_dottext post_id:_postIDtext handler:^(id result, NSUInteger code, NSError *error) {
            LOG(@"comment post result=%@, code=%@, error=%@", result, @(code), error);
            if ((code=200)) {
                //データ再習得
                [self perseJson];
                
                NSLog(@"result:%@",result);
                
                UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"コメント完了"
                                          delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                [alert show];
            }else{
                
                NSLog(@"ERROR : %@",error);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"書き込み出来ませんでした"
                                                               delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                [alert show];
                
            }
        }
         ];
        
        //セルの表示更新を行う
        [self viewWillAppear:YES];
        [self.tableView reloadData];
        //テキストビューの表示更新
        _textField.text = NULL;
        
        //キーボードを隠す
        [_textField resignFirstResponder];
    }
    
}




//[textField resignFirstResponder];

#pragma mark - UIScrollDelegate




#pragma mark - UITableViewDelegate&DataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//	// Return the number of sections.
//	return 1;
//}

#pragma mark 高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 75;
    
}



#pragma mark セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.8];
}

#pragma mark セル数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count:%lu",(unsigned long)[list_comments count]);
    return [list_comments count];
}

#pragma mark セル作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSInteger row_index = indexPath.row;
    
    Sample4TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Sample4TableViewCell"];
    if (!cell) {
        cell = [Sample4TableViewCell cell];
    }
    
    cell.UsersName.text =  [self.listUsername objectAtIndex:indexPath.row];
    NSLog(@"username:%@", [self.listUsername objectAtIndex:indexPath.row]);
    [cell.UsersPicture sd_setImageWithURL:[NSURL URLWithString: [self.listProfileImg objectAtIndex:indexPath.row]]
                             placeholderImage:[UIImage imageNamed:@"default.png"]
                                      options:0
                                     progress:nil
                                    completed:nil
         ];
    
   cell.Comment.text = [self.listComment objectAtIndex:indexPath.row];

    cell.DateOfComment.text = [self.listDate objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark 選択時
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    //[self performSegueWithIdentifier:SEGUE_GO_USERS_OTHERS sender:self];
    //NSLog(@"tap username:%@",postCommentname[indexPath.row]);
    //}
    
}

#pragma mark - ツールバー
#pragma mark ＜＝Modal Close
- (IBAction)onReturn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:SEGUE_GO_USERS_OTHERS])
    {
        //ここでパラメータを渡す
        UserpageViewController *userVC = segue.destinationViewController;
        userVC.postUsername = _postUsername;
    }
    if ([segue.identifier isEqualToString:SEGUE_GO_RESTAURANT])
    {
        //ここでパラメータを渡す
        RestaurantTableViewController  *restVC = segue.destinationViewController;
        restVC.postRestName = _postRestname;
    }
    
}

@end