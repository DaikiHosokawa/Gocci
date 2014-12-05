//
//  Sample5TableViewCell.h
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Profile_other;
@class Profile_otherPost;
@class Sample5TableViewCell_other;

@protocol Sample5TableViewCell_otherDelegate <NSObject>

/**
*  コメントボタンをタップ
*
*  @param cell
*  @param postID タップした投稿の post_id
*/
- (void)sample5TableViewCell_other:(Sample5TableViewCell_other *)cell didTapCommentWithPostID:(NSString *)postID;

/**
 *  Good ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
- (void)sample5TableViewCell_other:(Sample5TableViewCell_other *)cell didTapGoodWithPostID:(NSString *)postID;
/**
*  Restname ボタンをタップ
*
*  @param cell
*  @param postID タップした投稿の username
*/
- (void)sample5TableViewCell_other:(Sample5TableViewCell_other *)cell didTapRestnameWithrestname:(NSString *)restname;

@end

/**
 *  タイムライン画面 TableView の Cell
 */

@interface Sample5TableViewCell_other : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *restnameButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@property (nonatomic,weak) id<Sample5TableViewCell_otherDelegate> delegate;
@property (nonatomic,strong) Profile_other *comment;

/**
 *  セルの表示の更新
 *
 *  @param timelinePost
 */
- (void)configureWithProfile_otherPost:(Profile_otherPost *)profile_otherPost;

@end
