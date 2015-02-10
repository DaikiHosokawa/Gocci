//
//  Sample2TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Timeline;
@class TimelinePost;
@class TimelineCell;

extern NSString * const TimelineCellIdentifier;

@protocol TimelineCellDelegate <NSObject>

@optional

/**
 *  ユーザ名をタップ
 *
 *  @param cell
 *  @param userName タップした投稿の username
 */
- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserName:(NSString *)userName;

- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserPicture:(NSString *)userPicture;

@end

/**
 *  タイムライン画面 TableView の Cell
 */
@interface TimelineCell : UITableViewCell

@property (nonatomic,weak) id<TimelineCellDelegate> delegate;
@property (nonatomic,strong) Timeline *comment;
@property (nonatomic,weak) IBOutlet UIImageView *thumbnailView;

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
- (void)configureWithTimelinePost:(TimelinePost *)timelinePost;

/**
 *  データを反映した場合のセルの高さを計算
 *
 *  @param post
 *
 *  @return 
 */
+ (CGFloat)cellHeightWithTimelinePost:(TimelinePost *)post;

@end
