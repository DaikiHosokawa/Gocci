//
//  CustomTableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/05/16.
//  Copyright (c) 2015年 INASE,inc. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Dummy.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
    
    self.noticedAt.text = Notice.notice_date;
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:Notice.picture]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
}

@end
