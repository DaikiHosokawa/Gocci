//
//  Sample3TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample3TableViewCell.h"

@implementation Sample3TableViewCell
@synthesize UsersPicture;
@synthesize RestaurantName;
@synthesize Goodnum;
@synthesize Commentnum;
@synthesize thumbnailView;
@synthesize starImage;
@synthesize UsernameButton;

- (void)dealloc
{
    self.RestaurantName = nil;
    self.UsersPicture = nil;
    self.Goodnum = nil;
    self.contentViewFront = nil;
    self.Commentnum = nil;
    self.thumbnailView = nil;
    self.starImage = nil;
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
