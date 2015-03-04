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

@end
