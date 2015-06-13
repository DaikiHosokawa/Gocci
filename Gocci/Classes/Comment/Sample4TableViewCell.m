//
//  Sample4TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample4TableViewCell.h"

@implementation Sample4TableViewCell

- (void)dealloc
{
	self.UsersPicture = nil;
	self.UsersName = nil;
	self.Comment = nil;
};


- (void)awakeFromNib
{
	// Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

#pragma mark - Value
+(CGFloat)heightCell
{
	Sample4TableViewCell *cell = [Sample4TableViewCell cell];
	
	CGFloat height = cell.frame.size.height;
	
	return height;
}

#pragma mark - Initialize
+ (instancetype)cell
{
	return [[NSBundle mainBundle] loadNibNamed:@"Sample4TableViewCell" owner:self options:nil][0];
}

@end
