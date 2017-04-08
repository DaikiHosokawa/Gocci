//
//  CustomTableViewCell.h
//  Gocci
//
//  Created by kim on 2015/05/16.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notice.h"

@class Notice;
@class CustomTableViewCell;

@protocol CustomTableViewCellDelegate <NSObject>

@end

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *notificationMessage;
@property (weak, nonatomic) IBOutlet UILabel *noticedAt;

+ (CGFloat)rowHeight;

@property (nonatomic,weak) id<CustomTableViewCellDelegate> delegate;
/**
 *  TimelineCell を生成
 *
 *  @return
 */
+ (instancetype)cell;

/**
 *  セルの表示の更新
 *
 *  @param timelinePost
 */
- (void)configureWithNotice:(Notice *)Notice;


@end
