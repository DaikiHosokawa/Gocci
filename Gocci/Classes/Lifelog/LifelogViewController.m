//
//  LifelogViewController.m
//  Gocci
//
//  Created by INASE on 2015/02/01.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "LifelogViewController.h"
#import  "SVProgressHUD.h"
#import "APIClient.h"
#import "TimelinePost.h"
#import "NotificationViewController.h"

// !!!:dezamisystem
static NSString * const SEGUE_GO_LIFELOG_SUB = @"goLifelogSub";

@interface LifelogViewController ()

{
    JTCalendarMenuView *calendarMenuView;
    NSLayoutConstraint *calendarContentViewHeight;
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
    
}
- (void)showDefaultContentView;
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
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //右ナビゲーションアイテム(通知)の実装
    UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [customButton setImage:[UIImage imageNamed:@"bell"] forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // BBBadgeBarButtonItemオブジェクトの作成
    self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
    
    self.barButton.badgeBGColor      = [UIColor whiteColor];
    UIColor *color_custom = [UIColor colorWithRed:236./255. green:55./255. blue:54./255. alpha:1.];
    self.barButton.badgeTextColor    = color_custom;
    self.barButton.badgeOriginX = 10;
    self.barButton.badgeOriginY = 10;
    
    // バッジ内容の設定
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    self.navigationItem.rightBarButtonItem = self.barButton;
    
    
    /*
     //右ナビゲーションアイテム(通知)の実装
     // UIButton *wantButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
     
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"行きたい" style:UIBarButtonItemStylePlain target:self action:@selector(tapWantButton)];
     //  [barButtonItem setCustomView:wantButton];
     //左に設定する
     self.navigationItem.leftBarButtonItem = barButtonItem;
     */
    
    
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
        CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
        CGFloat width_image = height_image;
        UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
        UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        navigationTitle.image = image;
        self.navigationItem.titleView =navigationTitle;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
        barButton.title = @"";
        self.navigationItem.backBarButtonItem = barButton;
    }
    
    //set notificationCenter
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleRemotePushToUpdateBell:)
                               name:@"HogeNotification"
                             object:nil];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
    [self _fetchLifelog];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
        [self showDefaultContentView];
    }
    
    NSLog(@"ここが重い");
    //::[self.calendar reloadData]; // Must be call in viewDidAppear
}

- (void) handleRemotePushToUpdateBell:(NSNotification *)notification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    self.barButton.badgeValue = [NSString stringWithFormat : @"%ld", (long)[ud integerForKey:@"numberOfNewMessages"]];// ナビゲーションバーに設定する
    NSLog(@"badgeValue:%ld",(long)[ud integerForKey:@"numberOfNewMessages"]);
    self.navigationItem.rightBarButtonItem = self.barButton;
    
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
    
    int yearSelected = [self getYear:date];
    int monthSelected = [self getMonth:date];
    int daySelected = [self getDay:date];
    // NSIntegerを文字列に変換
    NSString *str1 = [NSString stringWithFormat:@"%04d", yearSelected];
    // NSIntegerを文字列に変換
    NSString *str2 = [NSString stringWithFormat:@"%02d", monthSelected];
    // NSIntegerを文字列に変換
    NSString *str3 = [NSString stringWithFormat:@"%02d", daySelected];
    NSString *str = [NSString stringWithFormat:@"%@-%@-%@",str1,str2,str3];
    AppDelegate* lifelogdelegate = [[UIApplication sharedApplication] delegate];
    lifelogdelegate.lifelogDate = str;
    NSLog(@"%s %04d-%02d-%02d",__func__, yearSelected,monthSelected,daySelected);
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

- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate10"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate10"];
    // 保存
    [userDefaults synchronize];
    // 初回起動
    return YES;
}


#pragma mark -
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
        descriptionLabel.text = @"思い出の記録や食生活管理に活かしましょう！";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}


/**
 *　全体タイムラインのデータを取得
 *
 *  @param usingLocationCache2 近くの投稿がなかった場合の全体のタイムライン表示
 */
- (void)_fetchLifelog
{
    [SVProgressHUD show];
    
    __weak typeof(self)weakSelf = self;
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        // API からデータを取得
        [APIClient LifelogWithHandler:^(id result, NSUInteger code, NSError *error)
         {
             LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             
             
             if (code != 200 || error != nil) {
                 // API からのデータの取得に失敗
                 // TODO: アラート等を掲出
                 return;
             }
             NSLog(@"result:%@",result);
             
             // 取得したデータを self.posts に格納
             NSMutableArray *tempPosts = [NSMutableArray arrayWithCapacity:0];
             for (NSDictionary *post in result) {
                 
                 [tempPosts addObject:post];
                 //NSLog(@"tempPosts:%@",resuglt);
             }
             NSLog(@"tempPosts:%@",tempPosts);
             //self.posts = [NSArray arrayWithArray:tempPosts];
             //年
             NSArray *year = [tempPosts valueForKey:@"year"];
             array_year = [year mutableCopy];
             NSLog(@"year:%@",array_year);
             //月
             NSArray *month = [tempPosts valueForKey:@"month"];
             array_month = [month mutableCopy];
             NSLog(@"month:%@",array_month);
             //日
             NSArray *day = [tempPosts valueForKey:@"day"];
             array_day = [day mutableCopy];
             NSLog(@"day:%@",array_day);
             
             if (!array_year || [array_year count] == 0) {
                 array_year = [[NSArray alloc] initWithObjects:@"2015",@"2015", nil];
             }
             if (!array_month || [array_month count] == 0) {
                 array_month = [[NSArray alloc] initWithObjects:@"02",@"02", nil];
             }
             if (!array_day || [array_day count] == 0) {
                 array_day = [[NSArray alloc] initWithObjects:@"15",@"28", nil];
             }
             [self.calendar reloadData];
             [SVProgressHUD dismiss];
         }];
    };
    
}

-(void)barButtonItemPressed:(id)sender{
    NSLog(@"badge touched");
    self.barButton.badgeValue = nil;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud removeObjectForKey:@"numberOfNewMessages"];
    
    if (!self.popover) {
        NotificationViewController *vc = [[NotificationViewController alloc] init];
        self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
    }
    NSLog(@"%f",self.barButton.accessibilityFrame.size.width);
    [self.popover presentPopoverFromRect:CGRectMake(
                                                    self.barButton.accessibilityFrame.origin.x + 15, self.barButton.accessibilityFrame.origin.y + 30, self.barButton.accessibilityFrame.size.width, self.barButton.accessibilityFrame.size.height)
                                  inView:self.barButton.customView
                permittedArrowDirections:WYPopoverArrowDirectionUp
                                animated:YES
                                 options:WYPopoverAnimationOptionFadeWithScale];
}


@end
