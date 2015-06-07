//
//  CustomTableViewCell.m
//  Gocci
//
//  Created by kim on 2015/05/16.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Dummy.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cell
{
    return [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil][0];
}

+ (CGFloat)rowHeight
{
    return 60.0f;
}

- (void)configureWithNotice:(Notice *)Notice
{
    self.notificationMessage.text = Notice.notice;
    self.noticedAt.text = Notice.noticed;
    // サムネイル画像
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:Notice.picture]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
}

@end
