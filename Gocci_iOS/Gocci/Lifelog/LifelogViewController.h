//
//  LifelogViewController.h
//  Gocci
//
//  Created by デザミ on 2015/02/01.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

#import "LifelogTableViewCell.h"


@interface LifelogViewController : UIViewController <LifelogTableViewCellDelegate, JTCalendarDataSource>

@property (strong, nonatomic) JTCalendarContentView *calendarContentView;

@property (strong, nonatomic) JTCalendar *calendar;

@end
