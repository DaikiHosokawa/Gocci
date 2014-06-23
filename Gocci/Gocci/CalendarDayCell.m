//
//  CalendarDayCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/18.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "CalendarDayCell.h"

@implementation CalendarDayCell



- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _notificationView = [[UIView alloc] init];
        [_notificationView setBackgroundColor:[UIColor blueColor]];
        [_notificationView setHidden:YES];
        [self.contentView addSubview:_notificationView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize viewSize = self.contentView.frame.size;
    
    [[self notificationView] setFrame:CGRectMake(viewSize.width - 10, 0, 10, 10)];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [[self notificationView] setHidden:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
