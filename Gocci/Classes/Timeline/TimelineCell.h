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
- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserName:(NSString *)userName picture:(NSString *)usersPicture;

- (void)timelineCell:(TimelineCell *)cell didTapNameWithUserPicture:(NSString *)userPicture name:(NSString *)userName;

/**
 *  店舗をタップ
 *
 *  @param cell
 *  @param restaurantName 店舗名
 */
- (void)timelineCell:(TimelineCell *)cell didTapRestaurant:(NSString *)restaurantName locality:(NSString *)locality tel:(NSString *)tel homepage:(NSString *)homepage category:(NSString *)category;

/**
 *  Like ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)timelineCell:(TimelineCell *)cell didTapLikeButtonWithPostID:(NSString *)postID;

/**
 *  Violate ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)timelineCell:(TimelineCell *)cell didTapViolateButtonWithPostID:(NSString *)postID;


/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID 
 */
- (void)timelineCell:(TimelineCell *)cell didTapCommentButtonWithPostID:(NSString *)Locality;

/**
 *  ナビをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)timelineCell:(TimelineCell *)cell didTapNaviWithLocality:(NSString *)postID;

/**
 *  Delete ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)timelineCell:(TimelineCell *)cell didTapDeleteWithPostID:(NSString *)postID;

@end

/**
 *  タイムライン画面 TableView の Cell
 */
@interface TimelineCell : UITableViewCell

@property (nonatomic,weak) id<TimelineCellDelegate> delegate;
@property (nonatomic,strong) Timeline *comment;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic,weak) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *ViolateView;

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
