//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Timeline;
@class TimelinePost;
@class TimelineCell;

extern NSString * const TimelineCellIdentifier;

@protocol TimelineCellDelegate <NSObject>

@optional

- (void)timelineCell:(TimelineCell *)cell didTapUserName:(NSString *)user_id;

- (void)timelineCell:(TimelineCell *)cell didTapPicture:(NSString *)user_id;

- (void)timelineCell:(TimelineCell *)cell didTapRestaurant:(NSString *)rest_id;

- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID;

- (void)timelineCell:(TimelineCell *)cell didTapthumb:(UIImageView *)thumbnailView;

- (void)timelineCell:(TimelineCell *)cell didTapViolateButtonWithPostID:(NSString *)postID;

- (void)timelineCell:(TimelineCell *)cell didTapCommentButtonWithPostID:(NSString *)Locality;

- (void)timelineCell:(TimelineCell *)cell didTapNaviWithLocality:(NSString *)postID;

- (void)timelineCell:(TimelineCell *)cell didTapDeleteWithPostID:(NSString *)postID;

@end

@interface TimelineCell : UITableViewCell
{
    int flash_on;
}

@property (nonatomic,weak) id<TimelineCellDelegate> delegate;
@property (nonatomic,strong) Timeline *comment;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic,weak) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *ViolateView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

+ (instancetype)cell;

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost;

+ (CGFloat)cellHeightWithTimelinePost:(TimelinePost *)post;

@end
