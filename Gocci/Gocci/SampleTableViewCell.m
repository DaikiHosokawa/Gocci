//
//  SampleTableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/02.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "SampleTableViewCell.h"

@implementation SampleTableViewCell
@synthesize restaurantAddress;
@synthesize restaurantName;
@synthesize meter;
@synthesize logo;

- (void)dealloc
{
self.restaurantName = nil;
self.restaurantAddress = nil;
self.meter = nil;
self.logo = nil;
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



@end
