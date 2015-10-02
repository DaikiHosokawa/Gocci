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
    return 78.0f;
}

- (void)configureWithNotice:(Notice *)Notice
{
   
    if ([Notice.noticeMessage isEqualToString:@"like"]) {
        NSLog(@"likeになる");
      self.notificationMessage.text = [NSString stringWithFormat:@"%@ %@",Notice.username,@"さんが投稿にいいねをつけました。"];
    } else if([Notice.noticeMessage isEqualToString:@"comment"])  {
         NSLog(@"commentになる");
     self.notificationMessage.text = [NSString stringWithFormat:@"%@ %@",Notice.username,@"さんが投稿にコメントをつけました。"];
    } else if([Notice.noticeMessage isEqualToString:@"follow"]) {
        self.notificationMessage.text = [NSString stringWithFormat:@"%@ %@",Notice.username,@"さんにフォローされました。"];
    }else if([Notice.noticeMessage isEqualToString:@"announce"]) {
        self.notificationMessage.text = [NSString stringWithFormat:@"%@ %@",Notice.username,@"さんが投稿にコメントをつけました。"];
    }
    
    //self.notificationMessage.text = Notice.noticeMessage;
    self.noticedAt.text = Notice.notice_date;
    // サムネイル画像
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:Notice.picture]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
}

@end
