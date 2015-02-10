//
//  JTCalendarWeekView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

@interface JTCalendarWeekView : UIView

@property (weak, nonatomic) JTCalendar *calendarManager;

@property (assign, nonatomic) NSUInteger currentMonthIndex;

- (void)setBeginningOfWeek:(NSDate *)date;
- (void)reloadData;
- (void)reloadAppearance;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
