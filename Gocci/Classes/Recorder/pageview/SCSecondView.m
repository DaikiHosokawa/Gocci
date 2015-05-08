//
//  SCSecondView.m
//  Gocci
//
//  Created by デザミ on 2015/05/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "SCSecondView.h"

#import "SCRecorderViewController.h"


static NSString * const CellIdentifier = @"SCSecondCell";

static NSString * const TextTenmei = @"店名";
static NSString * const TextCategory = @"カテゴリー";
static NSString * const TextKakaku = @"価格";
static NSString * const TextFuniki = @"雰囲気";

//グローバル
static int valueKakaku = 0;


@interface SCSecondView()
{
	__weak IBOutlet UITableView *tableviewList;
	
	NSArray *arrayCategory;
	NSArray *arrayFuniki;
	
	NSInteger selectedCategory;
	NSInteger selectedFuniki;
}
@property(nonatomic,strong) NSString *stringTenmei;
//@property(nonatomic,strong) NSString *stringKakaku;

@end

@implementation SCSecondView
@synthesize stringTenmei;
//@synthesize stringKakaku;

#pragma mark - addsubview
- (void)showInView:(UIView *)view offset:(CGPoint)offset
{
	self.frame = CGRectOffset(self.frame, offset.x, offset.y);
	
	{
//		tableviewList.delegate = self;
//		tableviewList.dataSource = self;
		
		arrayCategory = [[NSArray alloc] initWithObjects:@"和",@"洋",@"中", nil];
		arrayFuniki = [[NSArray alloc] initWithObjects:@"にぎやか",@"しずか",@"おしゃれ", nil];

		selectedCategory = -1;
		selectedFuniki = -1;
		stringTenmei = nil;
//		stringKakaku = nil;
	}
	
	[view addSubview:self];
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

#pragma mark 行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 4;
}

#pragma mark 高さ
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = self.frame.size.height / 4;
	
	return height;
}

#pragma mark 生成
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
			cell.textLabel.text = TextTenmei;
			if (stringTenmei) {
				cell.detailTextLabel.text = stringTenmei;
			}
			break;
		case 1:
			cell.textLabel.text = TextCategory;
			if (selectedCategory >= 0) {
				cell.detailTextLabel.text = [arrayCategory objectAtIndex:selectedCategory];
			}
			break;
		case 2:
			cell.textLabel.text = TextKakaku;
			if (valueKakaku) {
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d円",valueKakaku];
			}
			break;
		case 3:
			cell.textLabel.text = TextFuniki;
			if (selectedFuniki >= 0) {
				cell.detailTextLabel.text = [arrayFuniki objectAtIndex:selectedFuniki];
			}
			break;
	}

	return cell;
}

#pragma mark 色変更
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor blackColor];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.textColor = [UIColor whiteColor];
}

#pragma mark タップイベント
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"%s Row=%ld",__func__,(long)indexPath.row);
	
	//static NSString * const namebundle = @"";
	//
	
	UIViewController* rootViewController = nil;
	{
		CGRect rect = [UIScreen mainScreen].bounds;
		if (rect.size.height == 480) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
			//ビューコントローラ取得
			//viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			rootViewController = [storyboard instantiateInitialViewController];
		}
		else if (rect.size.height == 667) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
			//ビューコントローラ取得
			//viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			rootViewController = [storyboard instantiateInitialViewController];
		}
		else if (rect.size.height == 736) {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
			//ビューコントローラ取得
			//viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			rootViewController = [storyboard instantiateInitialViewController];
		}
		else {
			// ストーリーボードを取得
			UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			//ビューコントローラ取得
			//viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
			rootViewController = [storyboard instantiateInitialViewController];
		}
	}

	//__weak typeof(self)weakSelf = self;
	UIActionSheet *actionsheet = nil;
	switch (indexPath.row) {
		case 0:
			NSLog(@"店名");
			[self.delegate goBeforeRecorder];
			break;
			
		case 1:
			NSLog(@"カテゴリー");
			actionsheet = [[UIActionSheet alloc] initWithTitle:TextCategory
													   delegate:self
											  cancelButtonTitle:@"Cancel"
										 destructiveButtonTitle:nil
											  otherButtonTitles:[arrayCategory objectAtIndex:0],[arrayCategory objectAtIndex:1],[arrayCategory objectAtIndex:2], nil];
			actionsheet.tag = 1;
			[actionsheet showInView:rootViewController.view];
			break;

		case 2:
			NSLog(@"価格");
			[self.delegate goKakakuText];
			break;
			
		case 3:
			NSLog(@"雰囲気");
			actionsheet = [[UIActionSheet alloc] initWithTitle:TextFuniki
													  delegate:self
											 cancelButtonTitle:@"Cancel"
										destructiveButtonTitle:nil
											 otherButtonTitles:[arrayFuniki objectAtIndex:0],[arrayFuniki objectAtIndex:1],[arrayFuniki objectAtIndex:2], nil];
			actionsheet.tag = 3;
			[actionsheet showInView:rootViewController.view];
			break;
			
	}
	
	// 選択状態の解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//NSLog(@"%s sheet = %ld",__func__, (long)buttonIndex);
	
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		NSLog(@"cancel");
	}
	else {
		switch (actionSheet.tag) {
			case 1:
				//カテゴリー
				NSLog(@"%@",[arrayCategory objectAtIndex:buttonIndex]);
				selectedCategory = buttonIndex;
				
//				switch (buttonIndex) {
//					case 0:
//						break;
//					case 1:
//						//NSLog(@"洋");
//						break;
//					case 2:
//						//NSLog(@"中");
//						break;
//				}
				break;
			case 3:
				//雰囲気
				NSLog(@"%@",[arrayFuniki objectAtIndex:buttonIndex]);
				selectedFuniki = buttonIndex;
				
//				switch (buttonIndex) {
//					case 0:
//						//NSLog(@"にぎやか");
//						break;
//					case 1:
//						//NSLog(@"しずか");
//						break;
//					case 2:
//						//NSLog(@"おしゃれ");
//						break;
//				}
				break;
		}
		[tableviewList reloadData];
	}
}

#pragma mark - 代入
-(void)setTenmeiString:(NSString*)name
{
	stringTenmei = [NSString stringWithString:name];
	[tableviewList reloadData];
}
-(void)setKakakuValue:(int)value
{
	valueKakaku = value;
	[tableviewList reloadData];
}

#pragma mark - 生成
+ (instancetype)create
{
	NSString *nibName = @"SCSecondViewMain";
	//画面サイズから使用xibを場合分け
	CGRect rect = [UIScreen mainScreen].bounds;
	if (rect.size.height == 480) {
		//3.5inch
		nibName = @"SCSecondView_3_5_inch";
	}
	else if (rect.size.height == 667) {
		//4.7inch
		nibName = @"SCSecondView_4_7_inch";
	}
	else if (rect.size.height == 736) {
		//5.5inch
		nibName = @"SCSecondView_5_5_inch";
	}
	
	SCSecondView *view = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
	
	return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
