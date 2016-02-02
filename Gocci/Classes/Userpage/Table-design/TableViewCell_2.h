//
//  TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelinePost.h"

@class TableViewController_2;
@class TableViewCell_2;

@protocol TableViewCell_2Delegate <NSObject>

@optional

- (void)table:(TableViewCell_2 *)cell didTapRestname:(NSString *)rest_id;

- (void)table:(TableViewCell_2 *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)table:(TableViewCell_2 *)cell didTapThumb:(NSString*)rest_id;
- (void)table:(TableViewCell_2 *)cell didTapLikeButton:(NSString*)postID tapped:(BOOL)tapped;

@end

@interface TableViewCell_2 : UITableViewCell
{
    int flash_on;
}

@property (nonatomic, weak) IBOutlet UIImageView *thumbImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *option;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property(nonatomic,strong) id<TableViewCell_2Delegate> delegate;

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;

@end
