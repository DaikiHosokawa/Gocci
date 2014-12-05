//
//  Sample3TableViewCell.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Restaurant;
@class RestaurantPost;
@class Sample3TableViewCell;

@protocol Sample3TableViewCellDelegate <NSObject>

/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapCommentWithPostID:(NSString *)postID;

/**
 *  Good ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapGoodWithPostID:(NSString *)postID;

/**
 *  Name ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapNameWithusername:(NSString *)username;
- (void)sample3TableViewCell:(Sample3TableViewCell *)cell didTapNameWithuserspicture:(NSString *)userspicture;


@end

/**
 *  レストラン画面 TableView の Cell
 */

@interface Sample3TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *UsernameButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;


@property (nonatomic,weak) id<Sample3TableViewCellDelegate> delegate;
@property (nonatomic,strong) Restaurant *comment;

/**
 *  セルの表示の更新
 *
 *  @param timelinePost
 */
- (void)configureWithRestaurantPost:(RestaurantPost *)restaurantPost;

@end
