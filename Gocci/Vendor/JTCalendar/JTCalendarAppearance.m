//
//  JTCalendarAppearance.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarAppearance.h"


@implementation JTCalendarAppearance

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }
        
    [self setDefaultValues];
    
    return self;
}

- (void)setDefaultValues
{
	UIColor *color_custom_orange = [UIColor colorWithRed:245./255. green:43./255. blue:0. alpha:1.];  //245,43,0
	
    self.isWeekMode = NO;
    
    self.weekDayFormat = JTCalendarWeekDayFormatShort;
    
    self.ratioContentMenu = 2.;
    self.dayCircleRatio = 1.;
    self.dayDotRatio = 1. / 9.;
    
    self.menuMonthTextFont = [UIFont systemFontOfSize:17.];
    self.weekDayTextFont = [UIFont systemFontOfSize:11];
    self.dayTextFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    self.menuMonthTextColor = [UIColor blackColor];
	// !!!:dezamisystem
	self.weekDayTextColor = color_custom_orange; // [UIColor colorWithRed:152./256. green:147./256. blue:157./256. alpha:1.];
	
	// !!!:dezamisystem
//	[self setDayDotColorForAll:[UIColor colorWithRed:43./256. green:88./256. blue:134./256. alpha:1.]];
	[self setDayDotColorForAll:color_custom_orange];
	
    [self setDayTextColorForAll:[UIColor blackColor]];
    
    self.dayTextColorOtherMonth = [UIColor colorWithRed:152./256. green:147./256. blue:157./256. alpha:1.];

	// !!!:dezamisystem
	self.dayCircleColorSelected = [UIColor magentaColor]; //[UIColor redColor];
    self.dayTextColorSelected = [UIColor blackColor]; //[UIColor whiteColor];
	// !!!:dezamisystem
    self.dayDotColorSelected = [UIColor redColor]; //[UIColor whiteColor];
    
    self.dayCircleColorSelectedOtherMonth = self.dayCircleColorSelected;
    self.dayTextColorSelectedOtherMonth = self.dayTextColorSelected;
    self.dayDotColorSelectedOtherMonth = self.dayDotColorSelected;
	
	// 今日マーク
    self.dayCircleColorToday = [UIColor colorWithRed:0x33/256. green:0xB3/256. blue:0xEC/256. alpha:.5];
    self.dayTextColorToday = [UIColor whiteColor];
	// !!!:dezamisystem
    self.dayDotColorToday = [UIColor redColor]; //[UIColor whiteColor];
    
    self.dayCircleColorTodayOtherMonth = self.dayCircleColorToday;
    self.dayTextColorTodayOtherMonth = self.dayTextColorToday;
    self.dayDotColorTodayOtherMonth = self.dayDotColorToday;
}

- (NSCalendar *)calendar
{
    static NSCalendar *calendar;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        calendar.timeZone = [NSTimeZone localTimeZone];
    });
    
    return calendar;
}

- (void)setDayDotColorForAll:(UIColor *)dotColor
{
    self.dayDotColor = dotColor;
    self.dayDotColorSelected = dotColor;
    
    self.dayDotColorOtherMonth = dotColor;
    self.dayDotColorSelectedOtherMonth = dotColor;
    
    self.dayDotColorToday = dotColor;
    self.dayDotColorTodayOtherMonth = dotColor;
}

- (void)setDayTextColorForAll:(UIColor *)textColor
{
    self.dayTextColor = textColor;
    self.dayTextColorSelected = textColor;
    
    self.dayTextColorOtherMonth = textColor;
    self.dayTextColorSelectedOtherMonth = textColor;
    
    self.dayTextColorToday = textColor;
    self.dayTextColorTodayOtherMonth = textColor;
}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
