//
//  everyTableViewCell.h
//  Gocci
//
//  Created by INASE on 2015/06/12.
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
- (void)everyCell:(everyTableViewCell *)cell didTapUserName:(NSString *)user_id;
- (void)everyCell:(everyTableViewCell *)cell didTapPicture:(NSString *)user_id;

/**
 *  店舗をタップ
 *
 *  @param cell
 *  @param restaurantName 店舗名
 */
- (void)everyCell:(everyTableViewCell *)cell didTapRestaurant:(NSString *)rest_id;

/**
 *  Like ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)everyCell:(everyTableViewCell *)cell didTapLikeButtonWithPostID:(NSString *)postID;

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
 *  Violate ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)everyCell:(everyTableViewCell *)cell didTapViolateButtonWithPostID:(NSString *)postID;

@end



@interface everyTableViewCell : UITableViewCell
{
    int flash_on;
}
@property (nonatomic,weak) id<EveryCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
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
