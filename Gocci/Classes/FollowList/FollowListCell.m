//
//  FollowListCell.m
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "FollowListCell.h"

@implementation FollowListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)dealloc
{
    self.UsersPicture = nil;
    self.UsersName = nil;
};


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
