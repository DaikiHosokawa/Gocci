//
//  GaugeView.m
//  Gocci
//
//  Created by Daiki Hosokawa
//  Copyright (c) 2015年 INASE,inc. All rights reserved.
//

#import "GaugeView.h"

@interface GaugeView () {
	
	UIView *view_bar;
}

@end

@implementation GaugeView

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		
		//下地
		self.backgroundColor = [UIColor blackColor];
		
		//ゲージバー
		CGRect sub_frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
		view_bar = [[UIView alloc] initWithFrame:sub_frame];
		view_bar.backgroundColor = [UIColor colorWithRed:230./255. green:51./255. blue:51./255. alpha:1.];
		[self addSubview:view_bar];

	}
	return self;
}

-(void)updateWithPer:(float)per
{
	if (per > 1.f) per = 1.f;
	else if (per < 0.f) per = 0.f;
	
	CGAffineTransform t_scale = CGAffineTransformMakeScale(per, 1.f);
	
	float pos_x = (self.frame.size.width / 2) * (1.f - per);
	//if (isRight == NO)
	{
		pos_x = -pos_x;
	}
	CGAffineTransform t_pos = CGAffineTransformMakeTranslation(pos_x, 0.f);
	view_bar.transform = CGAffineTransformConcat(t_scale, t_pos);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
