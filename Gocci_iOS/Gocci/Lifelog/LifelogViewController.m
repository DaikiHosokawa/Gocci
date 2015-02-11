//
//  LifelogViewController.m
//  Gocci
//
//  Created by デザミ on 2015/02/01.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "LifelogViewController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_LIFELOG_SUB = @"goLifelogSub";

@interface LifelogViewController () {
	JTCalendarMenuView *calendarMenuView;
	NSLayoutConstraint *calendarContentViewHeight;
	
}
@property(nonatomic,strong) NSArray *array_year;
@property(nonatomic,strong) NSArray *array_month;
@property(nonatomic,strong) NSArray *array_day;

@end

@implementation LifelogViewController
@synthesize array_year;
@synthesize array_month;
@synthesize array_day;


#pragma mark - アイテム名登録用
-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
//		// !!!:dezamisystem・アイテム名
//		[self setTitle:@"ライフログ"];
//		// タブバーアイコン
//		UIImage *icon_normal = [UIImage imageNamed:@"tabbaritem_lifelog.png"];
//		UIImage *icon_selected = [UIImage imageNamed:@"tabbaritem_lifelog_sel.png"];
//		[self.tabBarItem setFinishedSelectedImage:icon_selected withFinishedUnselectedImage:icon_normal];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//ステータスバーの高さ
	//const CGFloat height_satus = [[UIApplication sharedApplication] statusBarFrame].size.height;
	//ナビゲーションバーの高さ
	//const CGFloat height_navigation = self.navigationController.navigationBar.frame.size.height;
	
	//座標
	const CGFloat width_view = self.view.frame.size.width;
	const CGFloat height_view = self.view.frame.size.height;
	const CGFloat height_content = width_view * 0.9;
	const CGFloat y_content = height_view / 2 - height_content / 2;
	const CGFloat height_menu = 24.0;
	const CGFloat y_menu = y_content - height_menu; // + height_navigation;
	
	// タイトル（月表示）バー
	calendarContentViewHeight = [[NSLayoutConstraint alloc] init];
	calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, y_menu, width_view, height_menu)];
	calendarMenuView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:calendarMenuView];
	
	// カレンダー
	//CGFloat y_origin = self.view.frame.size.height / 2 - width_view / 2;
	self.calendarContentView = [[JTCalendarContentView alloc] initWithFrame:CGRectMake(0, 0, width_view, height_content)];
	self.calendarContentView.center = CGPointMake(width_view/2., height_view/2.);
	self.calendarContentView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:self.calendarContentView];
	//
	
	self.calendar = [JTCalendar new];
	
	// All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
	// Or you will have to call reloadAppearance
	{
		self.calendar.calendarAppearance.calendar.firstWeekday = 1; // Sunday == 1, Saturday == 7
		self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
		self.calendar.calendarAppearance.ratioContentMenu = 1.;
	}
	
	//カレンダーデータセット
	[self.calendar setMenuMonthsView:calendarMenuView];
	[self.calendar setContentView:self.calendarContentView];
	[self.calendar setDataSource:self];
	
	
	
	//ナビゲーションバーに画像
	{
		//タイトル画像設定
		UIImageView *navigationTitle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"naviIcon.png"]];
		navigationTitle.frame = CGRectMake(0, 0, 44, 44);
		self.navigationItem.titleView =navigationTitle;
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
	//ナビゲーションバーに画像
	{
		//タイトル画像設定
		CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
		CGFloat width_image = height_image;
		UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
		UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
		self.navigationItem.titleView =navigationTitle;
	}

	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
	//JSONのパース処理
	NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/lifelogs"];
	NSString *encodeString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:encodeString];
	NSLog(@"url:%@",url);
	NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"response:%@",response);
	NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSLog(@"jsonData:%@",jsonData);
	NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	NSLog(@"jsonDic:%@",jsonDic);
	//年
	NSArray *year = [jsonDic valueForKey:@"year"];
	array_year = [year mutableCopy];
	//月
	NSArray *month = [jsonDic valueForKey:@"month"];
	array_month = [month mutableCopy];
	//日
	NSArray *day = [jsonDic valueForKey:@"day"];
	array_day = [day mutableCopy];
#else
	if (!array_year || [array_year count] == 0) {
		array_year = [[NSArray alloc] initWithObjects:@"2015",@"2015", nil];
	}
	if (!array_month || [array_month count] == 0) {
		array_month = [[NSArray alloc] initWithObjects:@"02",@"02", nil];
	}
	if (!array_day || [array_day count] == 0) {
		array_day = [[NSArray alloc] initWithObjects:@"15",@"28", nil];
	}
#endif
	
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.calendar reloadData]; // Must be call in viewDidAppear
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 変換
-(int)getYear:(NSDate *)date
{
	NSDateFormatter *formatter_year = [[NSDateFormatter alloc] init];
	[formatter_year setDateFormat:@"yyyy"];
	NSString *yearStr = [formatter_year stringFromDate:date];
	return [yearStr intValue];
}
-(int)getMonth:(NSDate *)date
{
	NSDateFormatter *formatter_month = [[NSDateFormatter alloc] init];
	[formatter_month setDateFormat:@"MM"];
	NSString *monthStr = [formatter_month stringFromDate:date];
	return [monthStr intValue];
}
-(int)getDay:(NSDate *)date
{
	NSDateFormatter *formatter_day = [[NSDateFormatter alloc] init];
	[formatter_day setDateFormat:@"dd"];
	NSString *dayStr = [formatter_day stringFromDate:date];
	return [dayStr intValue];
}

#pragma mark - 判定
-(BOOL)checkExistDataWithYear:(int)year Month:(int)month Day:(int)day
{
	for (int i = 0; i < [array_year count]; i++) {
		NSString *number_year = [array_year objectAtIndex:i];
		int valueYear = [number_year intValue];
		if (valueYear == year) {
			NSString *number_month = [array_month objectAtIndex:i];
			int valueMonth = [number_month intValue];
			if (valueMonth == month) {
				NSString *number_day = [array_day objectAtIndex:i];
				int valueDay = [number_day intValue];
				if (valueDay == day) {
					return YES;
				}
			}
		}
	}
	
	return NO;
}

#pragma mark - JTCalendarDataSource
// イベントマーカー
- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
	int yearSelected = [self getYear:date];
	int monthSelected = [self getMonth:date];
	int daySelected = [self getDay:date];
	if ([self checkExistDataWithYear:yearSelected Month:monthSelected Day:daySelected]) {
		return YES;
	}
	
	return NO;
}

//　日にち選択時
- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
	NSLog(@"Date: %@", date);
	
//	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//	[formatter setDateFormat:@"yyyy/MM/dd"];
//	NSString *dateStr = [formatter stringFromDate:date];
	
	int yearSelected = [self getYear:date];
	int monthSelected = [self getMonth:date];
	int daySelected = [self getDay:date];
	if ([self checkExistDataWithYear:yearSelected Month:monthSelected Day:daySelected]) {
		[self performSegueWithIdentifier:SEGUE_GO_LIFELOG_SUB sender:self];
	}
}

#pragma mark - Transition examples
- (void)transitionExample
{
	CGFloat newHeight = 300;
	if(self.calendar.calendarAppearance.isWeekMode){
		newHeight = 75.;
	}
	
	[UIView animateWithDuration:.5
					 animations:^{
						 calendarContentViewHeight.constant = newHeight;
						 [self.view layoutIfNeeded];
					 }];
	
	[UIView animateWithDuration:.25
					 animations:^{
						 self.calendarContentView.layer.opacity = 0;
					 }
					 completion:^(BOOL finished) {
						 [self.calendar reloadAppearance];
						 
						 [UIView animateWithDuration:.25
										  animations:^{
											  self.calendarContentView.layer.opacity = 1;
										  }];
					 }];
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
