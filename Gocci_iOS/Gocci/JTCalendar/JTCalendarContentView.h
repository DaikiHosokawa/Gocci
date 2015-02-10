//
//  JTCalendarContentView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

@class JTCalendar;

@interface JTCalendarContentView : UIScrollView

@property (weak, nonatomic) JTCalendar *calendarManager;

@property (strong, nonatomic) NSDate *currentDate;

- (void)loadPreviousMonth;
- (void)loadNextMonth;

- (void)reloadData;
- (void)reloadAppearance;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
