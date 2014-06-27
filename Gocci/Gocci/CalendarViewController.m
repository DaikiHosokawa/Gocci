//
//  CalendarViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/18.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarDayCell.h"

@interface CalendarViewController ()<RDVCalendarViewDelegate>

@end



@implementation CalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Calendar";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [[self.navigationController navigationBar] setTranslucent:NO];
    
    //ナビゲーションバーのアイテムの色を変更
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1.000]];
    
    //ナビゲーションバーの色を変更
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:1.00 green:0.07 blue:0.00 alpha:0.4];
    
    //ナビゲーションバーのタイトルの色を変更
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [[self calendarView] registerDayCellClass:[CalendarDayCell class]];
    
    
    //ナビゲーションバー右の"today"ボタン
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Today", nil)
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:[self calendarView]
                                                                   action:@selector(showCurrentMonth)];
    [self.navigationItem setRightBarButtonItem:todayButton];
    // Do any additional setup after loading the view
}
/*
- (void)calendarView:(RDVCalendarView *)calendarView configureDayCell:(RDVCalendarDayCell *)dayCell
             atIndex:(NSInteger)index {
    CalendarDayCell *exampleDayCell = (CalendarDayCell *)dayCell;
    if (index % 5 == 0) {
        [[exampleDayCell notificationView] setHidden:NO];
    }
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
