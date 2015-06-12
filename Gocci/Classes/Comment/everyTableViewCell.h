//
//  everyTableViewCell.h
//  Gocci
//
//  Created by デザミ on 2015/06/12.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Timeline;
@class EveryPost;
//@class TimelinePost;
//@class TimelineCell;
@class everyTableViewCell;

extern NSString * const EveryCellIdentifier;

@protocol EveryCellDelegate <NSObject>

@optional
/**
 *  ユーザ名をタップ
 *
 *  @param cell
 *  @param userName タップした投稿の username
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapNameWithUserName:(NSString *)userName picture:(NSString *)usersPicture flag:(NSInteger )flag;

- (void)timelineCell:(everyTableViewCell *)cell didTapNameWithUserPicture:(NSString *)userPicture name:(NSString *)userName flag:(NSInteger)flag;

/**
 *  店舗をタップ
 *
 *  @param cell
 *  @param restaurantName 店舗名
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapRestaurant:(NSString *)restaurantName locality:(NSString *)locality tel:(NSString *)tel homepage:(NSString *)homepage category:(NSString *)category lon:(NSString *)lon lat:(NSString *)lat total_cheer:(NSString *)total_cheer want_tag:(NSString *)want_tag;

/**
 *  Like ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapLikeButtonWithPostID:(NSString *)postID;

/**
 *  サムネイルをタップ
 *
 *  @param cell
 *  @param restaurantName 店舗名
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapthumb:(UIImageView *)thumbnailView;


/**
 *  Violate ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapViolateButtonWithPostID:(NSString *)postID;


/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapCommentButtonWithPostID:(NSString *)Locality;

/**
 *  ナビをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapNaviWithLocality:(NSString *)postID;

/**
 *  Delete ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)timelineCell:(everyTableViewCell *)cell didTapDeleteWithPostID:(NSString *)postID;

@end



@interface everyTableViewCell : UITableViewCell
@property (nonatomic,weak) id<EveryCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

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
- (void)configureWithTimelinePost:(EveryPost *)timelinePost;

/**
 *  データを反映した場合のセルの高さを計算
 *
 *  @param post
 *
 *  @return
 */
+ (CGFloat)cellHeightWithTimelinePost:(EveryPost *)post;

@end
