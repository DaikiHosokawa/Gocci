//
//  Sample2TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Profile2;
@class TimelinePost;
@class ProfileCell2;

extern NSString * const Profile2CellIdentifier;

@protocol Profile2CellDelegate <NSObject>

@optional

/**
 *  ユーザ名をタップ
 *
 *  @param cell
 *  @param userName タップした投稿の username
 */
- (void)profileCell2:(ProfileCell2 *)cell didTapNameWithUserName:(NSString *)userName picture:(NSString *)usersPicture;

- (void)profileCell2:(ProfileCell2 *)cell didTapNameWithUserPicture:(NSString *)userPicture name:(NSString *)userName;

/**
 *  店舗をタップ
 *
 *  @param cell
 *  @param restaurantName 店舗名
 */
- (void)profileCell2:(ProfileCell2 *)cell didTapRestaurant:(NSString *)restaurantName locality:(NSString *)locality tel:(NSString *)tel homepage:(NSString *)homepage category:(NSString *)category;

/**
 *  Like ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)profileCell2:(ProfileCell2 *)cell didTapLikeButtonWithPostID:(NSString *)postID;

/**
*  サムネイルをタップ
*
*  @param cell
*  @param restaurantName 店舗名
*/
- (void)profileCell2:(ProfileCell2 *)cell didTapthumb:(UIImageView *)thumbnailView;


/**
 *  Violate ボタンをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)profileCell2:(ProfileCell2 *)cell didTapViolateButtonWithPostID:(NSString *)postID;


/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID 
 */
- (void)profileCell2:(ProfileCell2 *)cell didTapCommentButtonWithPostID:(NSString *)Locality;

/**
 *  ナビをタップ
 *
 *  @param cell
 *  @param postID
 */
- (void)profileCell2:(ProfileCell2 *)cell didTapNaviWithLocality:(NSString *)postID;

/**
 *  Delete ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)profileCell2:(ProfileCell2 *)cell didTapDeleteWithPostID:(NSString *)postID;

@end

/**
 *  タイムライン画面 TableView の Cell
 */
@interface ProfileCell2 : UITableViewCell

@property (nonatomic,weak) id<Profile2CellDelegate> delegate;
@property (nonatomic,strong) Profile2 *comment;
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
