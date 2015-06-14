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
#import "everyTableViewCell.h"
#import "EveryPost.h"
#import "MoviePlayerManager.h"
#import "commentTableViewCell.h"


@interface everyTableViewController ()<EveryCellDelegate>
{
	DemoContentView *_firstContentView;
	DemoContentView *_secondContentView;
	
	NSArray *list_comments;
	EveryPost *myPost;
}

- (void)showDefaultContentView;
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
	[self.tableView registerNib:nib forCellReuseIdentifier:@"EveryTableViewCell"];
	
	//背景にイメージを追加したい
	// UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
	// self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
	backButton.title = @"";
	
	self.tableView.bounces = NO;
	self.tableView.allowsSelection = NO;
//	self.tableView.separatorColor = [UIColor clearColor];
	_textField.placeholder = @"ここにコメントを入力してください。";
	
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
	[SVProgressHUD show];
	[super viewWillAppear:animated];
	
	// !!!:dezamisystem
	[self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
	
	[SVProgressHUD dismiss];
	
	_postIDtext = _postID;
	NSLog(@"postIDtext:%@",_postIDtext);
	
	[self perseJson];
	
	// キーボードの表示・非表示がNotificationCenterから通知される
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark viewDidAppear
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([self isFirstRun]) {
		//Calling this methods builds the intro and adds it to the screen. See below.
		[self showDefaultContentView];
	}
}
- (BOOL)isFirstRun
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults objectForKey:@"firstRunDate3"]) {
		// 日時が設定済みなら初回起動でない
		return NO;
	}
	// 初回起動日時を設定
	[userDefaults setObject:[NSDate date] forKey:@"firstRunDate3"];
	// 保存
	[userDefaults synchronize];
	// 初回起動
	return YES;
}
- (void)showDefaultContentView
{
	if (!_firstContentView) {
		_firstContentView = [DemoContentView defaultView];
		
		UILabel *descriptionLabel = [[UILabel alloc] init];
		descriptionLabel.frame = CGRectMake(20, 8, 260, 100);
		descriptionLabel.numberOfLines = 0.;
		descriptionLabel.textAlignment = NSTextAlignmentCenter;
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor blackColor];
		descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.];
		descriptionLabel.text = @"投稿者と会話ができます。";
		[_firstContentView addSubview:descriptionLabel];
		
		[_firstContentView setDismissHandler:^(DemoContentView *view) {
			// to dismiss current cardView. Also you could call the `dismiss` method.
			[CXCardView dismissCurrent];
		}];
	}
	
	[CXCardView showWithView:_firstContentView draggable:YES];
}

#pragma mark viewWillDisappear
-(void)viewWillDisappear:(BOOL)animated
{
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
	
	[super viewWillDisappear:animated];
}

#pragma mark - Json
-(void)perseJson
{
	//test user
	//_postIDtext = @"3024";
	
	//JSONをパース
	NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/commentpage/?post_id=%@",_postIDtext];
	
	NSLog(@"Timeline Api:%@",urlString);
	NSURL *url = [NSURL URLWithString:urlString];
	NSError *err = nil;
	NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
	if (err) {
		NSLog(@"%s %@",__func__,err);
		//NSLog(@"ERROR : %s",__func__);
		return;
	}
	NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	err = nil;
	NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
	if (err) {
		NSLog(@"%s %@",__func__,err);
		//NSLog(@"ERROR : %s",__func__);
		return;
	}
	//NSLog(@"%@",jsonDic);
	
	NSArray *d_comments = [jsonDic objectForKey:@"comments"];
	list_comments = [[NSArray alloc] initWithArray:d_comments];
	//NSLog(@"%@",list_comments);
	
	NSDictionary *d_post = [jsonDic objectForKey:@"post"];
	myPost = [EveryPost everyPostWithJsonDictionary:d_post];
}

/**
 *  現在表示中のセルの動画を再生する
 */
- (void)_playMovieAtCurrentCell
{
	/*
	 if ( [self.posts count] == 0){
	 return;
	 }
	 */
	
	if (self.tabBarController.selectedIndex != 0) {
		// 画面がフォアグラウンドのときのみ再生
		return;
	}
 
	NSInteger currentIndexRow = 0;
	CGFloat currentHeight = 0.0;
//	for (NSUInteger i=0; i < [self _currentIndexPath].row; i++) {
//		if ([self.posts count] <= i) continue;
//		
//		currentHeight += [TimelineCell cellHeightWithTimelinePost:self.posts[i]];
//	}
	
	currentHeight += [everyTableViewCell cellHeightWithTimelinePost:myPost];
	
	everyTableViewCell *currentCell = [everyTableViewCell cell];
	[currentCell configureWithTimelinePost:myPost];
	CGRect movieRect = CGRectMake((self.tableView.frame.size.width - currentCell.thumbnailView.frame.size.width) / 2,
								  currentHeight + currentCell.thumbnailView.frame.origin.y,
								  currentCell.thumbnailView.frame.size.width,
								  currentCell.thumbnailView.frame.size.height);
	
	
	[[MoviePlayerManager sharedManager] scrolling:NO];
	[[MoviePlayerManager sharedManager] playMovieAtIndex:currentIndexRow
												  inView:self.tableView
												   frame:movieRect];
	
}

#pragma mark - アクション
- (IBAction)pushSendBtn:(id)sender
{
	_dottext = _textField.text;
	
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
		NSString *content = [NSString stringWithFormat:@"comment=%@&post_id=%@",_dottext,_postIDtext];
		NSLog(@"content:%@",content);
		
		NSString *urlString = @"http://api-gocci.jp/comment/";
		NSURL* url = [NSURL URLWithString:urlString];
		NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
		NSURLResponse* response;
		NSError* error = nil;
		NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
											   returningResponse:&response
														   error:&error];
		if (error) {
			NSLog(@"ERROR : %@",error);
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"書き込み出来ませんでした"
									  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
			[alert show];
		}
		else
		{
			//データ再習得
			[self perseJson];

			NSLog(@"result:%@",result);
			
			UIAlertView *alert =
			[[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"コメント完了"
									  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
			[alert show];
		}
		
	}
	//セルの表示更新を行う
	[self viewWillAppear:YES];
	[self.tableView reloadData];
	//テキストビューの表示更新
	_textField.text = NULL;
	
	//キーボードを隠す
	[_textField resignFirstResponder];
}

// キーボードが表示される時に呼び出される
- (void)keyboardWillShow:(NSNotification *)notification
{
	// キーボードのサイズ
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// キーボード表示アニメーションのduration
	NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	// viewのアニメーション
	[UIView animateWithDuration:duration animations:^{
		CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -keyboardRect.size.height+10);
		self.view.transform = transform;
	} completion:NULL];
}

// キーボードが非表示になる時に呼び出される
- (void)keyboardWillHide:(NSNotification *)notification {
	// キーボード表示アニメーションのduration
	NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	
	__weak typeof(self) _self = self;
	[UIView animateWithDuration:duration animations:^{
		_self.view.transform = CGAffineTransformIdentity;
	} completion:NULL];
}

//[textField resignFirstResponder];

#pragma mark - UIScrollDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(!decelerate) {
		// ドラッグ終了 かつ 加速無し
//		LOG(@"scroll is stoped");
		
//		[self _playMovieAtCurrentCell];
	}
}

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

#pragma mark - UITableViewDelegate&DataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//	// Return the number of sections.
//	return 1;
//}

#pragma mark 高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSInteger row_index = indexPath.row;

	CGFloat height = 100.f;
	if (row_index % 2) {
		//Comment
		height = [commentTableViewCell heightCell];
	}
	else {
		//POST
		height = [everyTableViewCell cellHeightWithTimelinePost:myPost];
	}
	
	return height;
}

#pragma mark セルの透過処理
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:0.8];
}

#pragma mark セル数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger count = 1 + 1; // POST用セル + コメント用セル
	
	return count;
}

#pragma mark セル作成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row_index = indexPath.row;
	
	if (row_index % 2) {
		//コメントセル
		commentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
		if (!cell) {
			cell = [commentTableViewCell cell];
		}
		
		//セルにデータ反映
		[cell configureWithArray:list_comments];
		
		//終了
		return cell;
	}
	
	//ポストセル
	NSString *cellIdentifier = EveryCellIdentifier;
	everyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell){
		cell = [everyTableViewCell cell];
	}
		
	// セルにデータを反映
	[cell configureWithTimelinePost:myPost];
	cell.delegate = self;
		
	// 動画の読み込み
	//__weak typeof(self)weakSelf = self;
	//[[MoviePlayerManager sharedManager] addPlayerWithMovieURL:myPost.movie
	//														 size:cell.thumbnailView.bounds.size
	//													  atIndex:indexPath.row
	//												   completion:^(BOOL f){}];
	[SVProgressHUD dismiss];

	return cell;
}

#pragma mark 選択時
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
 
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

#pragma mark - ツールバー
#pragma mark ＜＝Modal Close
- (IBAction)onReturn:(id)sender {
	
	[self dismissViewControllerAnimated:YES completion:^{
            //
	}];
}

@end