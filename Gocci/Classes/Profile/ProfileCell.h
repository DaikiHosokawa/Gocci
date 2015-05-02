//
//  Sample2TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Profile;
@class TimelinePost;
@class ProfileCell;

extern NSString * const ProfileCellIdentifier;

@protocol ProfileCellDelegate <NSObject>

@optional

/**
 *  ユーザ名をタップ
 *
 *  @param cell
 *  @param userName タップした投稿の username
 */
- (void)profileCell:(ProfileCell *)cell didTapNameWithUserName:(NSString *)userName picture:(NSString *)usersPicture;

- (void)profileCell:(ProfileCell *)cell didTapNameWithUserPicture:(NSString *)userPicture name:(NSString *)userName;

/**
 *  店舗をタップ
 *
 *  @param cell
 *  @param restaurantName 店舗名
 */
- (void)profileCell:(ProfileCell *)cell didTapRestaurant:(NSString *)restaurantName locality:(NSString *)locality tel:(NSString *)tel homepage:(NSString *)homepage category:(NSString *)category;

/**
 *  Like ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)profileCell:(ProfileCell *)cell didTapLikeButtonWithPostID:(NSString *)postID;

/**
*  サムネイルをタップ
*
*  @param cell
*  @param restaurantName 店舗名
*/
- (void)profileCell:(ProfileCell *)cell didTapthumb:(UIImageView *)thumbnailView;


/**
 *  Violate ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)profileCell:(ProfileCell *)cell didTapViolateButtonWithPostID:(NSString *)postID;


/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID 
 */
- (void)profileCell:(ProfileCell *)cell didTapCommentButtonWithPostID:(NSString *)Locality;

/**
 *  ナビをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)profileCell:(ProfileCell *)cell didTapNaviWithLocality:(NSString *)postID;

/**
 *  Delete ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)profileCell:(ProfileCell *)cell didTapDeleteWithPostID:(NSString *)postID;

@end

/**
 *  タイムライン画面 TableView の Cell
 */
@interface ProfileCell : UITableViewCell

@property (nonatomic,weak) id<ProfileCellDelegate> delegate;
@property (nonatomic,strong) Profile *comment;
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
