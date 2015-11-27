//
//  TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelinePost.h"

@class TableViewController;
@class TableViewCell;

@protocol TableViewCellDelegate <NSObject>

@optional

- (void)table:(TableViewCell *)cell didTapRestname:(NSString *)rest_id;

- (void)table:(TableViewCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)table:(TableViewCell *)cell didTapThumb:(NSString*)rest_id;
- (void)table:(TableViewCell *)cell didTapLikeButton:(NSString*)postID;

@end

@interface TableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *option;

@property(nonatomic,strong) id<TableViewCellDelegate> delegate;

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;

@end
