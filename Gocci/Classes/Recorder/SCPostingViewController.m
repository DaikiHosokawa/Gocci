//
//  SCPostingViewController.m
//  Gocci
//
//  Created by デザミ on 2015/05/08.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "SCPostingViewController.h"

#import "SCRecorderViewController.h"
#import "AppDelegate.h"


static NSString * const SEGUE_GO_KAKAKUTEXT = @"goKakaku";
static NSString * const SEGUE_GO_BEFORE_RECORDER = @"goBeforeRecorder";

static NSString * const CellIdentifier = @"CellIdentifierSocial";

@interface SCPostingViewController ()
{
	__weak IBOutlet UIView *viewsecond;
	__weak IBOutlet UIImageView *imageview_samnail;
	__weak IBOutlet UIView *view_social;
	
	SCSecondView *secondView;
	
	UITableView *tableviewSocial;
}

@end

@implementation SCPostingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	//ナビゲーションバーに画像
	{
		//CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
		UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
		UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		navigationTitle.image = image;
		self.navigationItem.titleView = navigationTitle;
		
		//バックボタンカスタマイズ
		UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
		barButton.title = @"Cancel";
		self.navigationItem.backBarButtonItem = barButton;
	}

	{
		secondView = [SCSecondView create];
		secondView.delegate = self;
		[secondView showInView:viewsecond offset:CGPointZero back:1];
	}
	
	{
		tableviewSocial = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view_social.frame.size.width, view_social.frame.size.height)
													   style:UITableViewStylePlain];
		tableviewSocial.delegate = self;
		tableviewSocial.dataSource = self;
		tableviewSocial.scrollEnabled = NO;
		[view_social addSubview:tableviewSocial];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{	
	// NavigationBar 非表示
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	[secondView setKakakuValue:delegate.valueKakaku];
	[secondView setTenmeiString:delegate.stringTenmei];
	[secondView setCategoryIndex:delegate.indexCategory];
	[secondView setFunikiIndex:delegate.indexFuniki];
	[secondView reloadTableList];
	
	[super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//NSLog(@"%@", self.navigationItem.backBarButtonItem.title);
	
}

-(void)viewWillDisappear:(BOOL)animated
{
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
	{
		//NSLog(@" %s back!",__func__);
		// 戻るボタンが押された処理
		[[self viewControllerSCRecorder] cancelSubmit];
	}
	[super viewWillDisappear:animated];
}

#pragma mark - アクション
- (IBAction)onSubmit:(id)sender
{
	[[self viewControllerSCRecorder] execSubmit];
}

#pragma mark - 取得
-(SCRecorderViewController*)viewControllerSCRecorder
{
	static NSString * const namebundle = @"screcorder";
	
	SCRecorderViewController* viewController = nil;
	{
		CGRect rect = [UIScreen mainScreen].bounds;
		if (rect.size.height == 480) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
		}
		else if (rect.size.height == 667) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
		}
		else if (rect.size.height == 736) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
		}
		else {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			//ビューコントローラ取得
			viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
		}
	}

	return viewController;
}

#pragma mark - SCSecondView
-(void)goBeforeRecorder
{
	//遷移：beforeRecorderTableViewController
	[self performSegueWithIdentifier:SEGUE_GO_BEFORE_RECORDER sender:self];
}
-(void)goKakakuText
{
	//遷移：SCRecorderVideoController
	[self performSegueWithIdentifier:SEGUE_GO_KAKAKUTEXT sender:self];
}

#pragma mark - TableViewSocial
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return view_social.frame.size.height /2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSInteger row_index = indexPath.row;
	switch (row_index) {
		case 0:
			cell.textLabel.text = @"twitter";
			break;
		case 1:
			cell.textLabel.text = @"facebook";
			break;
	}
	
	return cell;
}

#pragma mark 色変更
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor whiteColor];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.detailTextLabel.textColor = [UIColor blackColor];
}

#pragma mark タップイベント
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.row) {
		case 0:
			NSLog(@"%s twitte",__func__);
			break;
			
		case 1:
			NSLog(@"%s facebook",__func__);
			break;
	}
	
	// 選択状態の解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
