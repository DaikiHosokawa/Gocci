//
//  everyTableViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "everyTableViewController.h"
#import "TimelineTableViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface everyTableViewController ()
@property (nonatomic, retain) NSMutableArray *picture_;
@property (nonatomic, readwrite) NSMutableArray *comment_;
@property (nonatomic, retain) NSMutableArray *user_name_;
@property (nonatomic, retain) Sample4TableViewCell *cell;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, retain) NSString *dottext;
@property (nonatomic, retain) NSString *postIDtext;
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

-(void)viewWillAppear:(BOOL)animated{
  [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
  
    
    [SVProgressHUD dismiss];
    _postIDtext = _postID;
    NSLog(@"postIDtext:%@",_postIDtext);
    //JSONをパース
    NSString *timelineString = [NSString stringWithFormat:@"http://api-gocci.jp/api/public/comment_json/?post_id=%@",_postIDtext];
    NSLog(@"Timeline Api:%@",timelineString);
    NSURL *url = [NSURL URLWithString:timelineString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    // ユーザー名
    NSArray *user_name = [jsonDic valueForKey:@"user_name"];
    _user_name_ = [user_name mutableCopy];
    NSLog(@"user_name:%@",_user_name_);
    // プロフ画像
    NSArray *picture = [jsonDic valueForKey:@"picture"];
    _picture_ = [picture mutableCopy];
    //コメント内容
    NSArray *comment = [jsonDic valueForKey:@"comment"];
    _comment_ = [comment mutableCopy];
        
    // キーボードの表示・非表示がNotificationCenterから通知される
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    }
- (IBAction)pushSendBtn:(id)sender {
    _dottext = _textField.text;
    if (_textField.text.length == 0) {
        //アラート出す
        NSLog(@"textlength:%lu",(unsigned long)_textField.text.length);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"コメントを入力してください"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
    
        
    NSLog(@"コメント内容:%@",_dottext);
    NSLog(@"sendBtn is touched");;
    NSString *content = [NSString stringWithFormat:@"comment=%@&post_id=%@",_dottext,_postIDtext];
    NSLog(@"content:%@",content);
    NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/api/public/comment/"];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLResponse* response;
    NSError* error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                           returningResponse:&response
                                                       error:&error];
        NSLog(@"result:%@",result);
   
    //アラート出す
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"コメント完了"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
    
    }
    //セルの表示更新を行う
   [self viewWillAppear:YES];
   [self.tableView reloadData];
   //テキストビューの表示更新
    _textField.text = NULL;
    
    
    //キーボードを隠す
    [_textField resignFirstResponder];
}



-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
    
    // キーボードの表示・非表示はNotificationCenterから通知されますよっと
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 通知の受け取りを解除する
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillShowNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:UIKeyboardWillHideNotification
                           object:nil];
    }


- (void)viewDidLoad
{
     /*
    // UIImageを指定した生成例
    UIImage *image = [UIImage imageNamed:@"gocci-moji.png"];
    UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = myImageView;
    */
    
    self.navigationItem.title = @"コメント画面";
    
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"Sample4TableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"EveryTableViewCell"];

    //背景にイメージを追加したい
   // UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
   // self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"";
    self.navigationItem.backBarButtonItem = backButton;
    self.tableView.bounces = NO;
     self.tableView.allowsSelection = NO;
    _textField.placeholder = @"ここにコメントを入力してください。";
    
   }

// キーボードが表示される時に呼び出されますー
- (void)keyboardWillShow:(NSNotification *)notification {
    // キーボードのサイズ
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // キーボード表示アニメーションのduration
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // viewのアニメーション
    [UIView animateWithDuration:duration animations:^{
        // ここをframeわざわざ計算してる人おおいですねー
        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -keyboardRect.size.height+10);
        self.view.transform = transform;
    } completion:NULL];
}

// キーボードが非表示になる時に呼び出されますー
- (void)keyboardWillHide:(NSNotification *)notification {
    // キーボード表示アニメーションのduration
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    __weak typeof(self) _self = self;
    [UIView animateWithDuration:duration animations:^{
        // tranformで動かしておけば、戻すときはこれだけ!
        _self.view.transform = CGAffineTransformIdentity;
    } completion:NULL];
}


//[textField resignFirstResponder];



#pragma mark - UIActivityItemSource


//Twitterのアクティビティ動作
-(id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    // Twitterの時だけハッシュタグをつける
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return [NSString stringWithFormat:@"%@ #%@", _text, _hashTag];
    }
    return _text;
}

-(id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return _text;
}


//アクションボタンを押した時の動作
- (IBAction)share:(id)sender
{
    everyTableViewController *text = [[everyTableViewController alloc] initWithText:@"本文はこちらです。" hashTag:@"Gocci"];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger test = [_comment_ count];
    NSLog(@"test:%ld",(long)test);
    if([_comment_ count] == 0){
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
    return 7;}
    if([_comment_ count] == 1){
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        return 7;}
    if([_comment_ count] == 2){
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        return 7;}
    if([_comment_ count] == 3){
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        return 7;}
    if([_comment_ count] == 4){
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        return 7;}
    if([_comment_ count] == 5){
        [_comment_ addObject:@""];
        [_comment_ addObject:@""];
        [_user_name_ addObject:@""];
        [_user_name_ addObject:@""];
        [_picture_ addObject:@""];
        [_picture_ addObject:@""];
        return 7;}
    if([_comment_ count] == 6){
        [_comment_ addObject:@""];
        [_user_name_ addObject:@""];
        [_picture_ addObject:@""];
        return 7;}
    else{
        return [_comment_ count];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _cell = (Sample4TableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"EveryTableViewCell"];
    
    
    _cell.UsersName.text = [_user_name_ objectAtIndex:indexPath.row];
    _cell.Comment.text= [_comment_ objectAtIndex:indexPath.row];
    _cell.Comment.text = [_comment_ objectAtIndex:indexPath.row];
    _cell.Comment.text = [_comment_ objectAtIndex:indexPath.row];
    _cell.Comment.textAlignment = NSTextAlignmentLeft;
    _cell.Comment.numberOfLines = 2;
    
    if([_picture_ objectAtIndex:indexPath.row] != nil){
    //ユーザーの画像を取得
    NSString *dottext = [_picture_ objectAtIndex:indexPath.row];
    // Here we use the new provided setImageWithURL: method to load the web image
    [_cell.UsersPicture setImageWithURL:[NSURL URLWithString:dottext]
                       placeholderImage:[UIImage imageNamed:@"default.png"]];
    }
    
    return _cell;
}




@end