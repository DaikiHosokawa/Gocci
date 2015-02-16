//
//  LifelogViewController.h
//  Gocci
//
//  Created by デザミ on 2015/02/01.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

#import "AppDelegate.h"

#import "CXCardView.h"
#import "DemoContentView.h"



@interface LifelogViewController : UIViewController <JTCalendarDataSource>

@property (strong, nonatomic) JTCalendarContentView *calendarContentView;

@property (strong, nonatomic) JTCalendar *calendar;

@end
