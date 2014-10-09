//
//  Sample5TableViewCell.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample5TableViewCell.h"

@implementation Sample5TableViewCell

@synthesize UsersName;
@synthesize UsersPicture;
@synthesize RestaurantName;
@synthesize Goodnum;
@synthesize Review;
@synthesize Commentnum;

- (void)dealloc
{
    self.RestaurantName = nil;
    self.UsersPicture = nil;
    self.UsersName = nil;
    self.Goodnum = nil;
    self.Review = nil;
    self.contentViewFront = nil;
    self.Commentnum = nil;
};


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
