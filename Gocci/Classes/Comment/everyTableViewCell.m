//
//  everyTableViewCell.m
//  Gocci
//
//  Created by デザミ on 2015/06/12.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "everyTableViewCell.h"

@interface everyTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avaterImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation everyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
