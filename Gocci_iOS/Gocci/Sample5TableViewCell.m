//
//  Sample5TableViewCell.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample5TableViewCell.h"

@implementation Sample5TableViewCell


@synthesize Goodnum;
@synthesize Commentnum;
@synthesize deleteBtn;
@synthesize starImage;
@synthesize RestnameButton;

- (void)dealloc
{
    self.Goodnum = nil;
    self.contentViewFront = nil;
    self.Commentnum = nil;
    self.deleteBtn = nil;
    self.starImage = nil;
};


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
