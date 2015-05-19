//
//  CustomTableViewCell.m
//  Gocci
//
//  Created by kim on 2015/05/16.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)rowHeight
{
    return 60.0f;
}

@end
