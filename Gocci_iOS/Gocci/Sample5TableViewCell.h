//
//  Sample5TableViewCell.h
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Profile;
@class ProfilePost;
@class Sample5TableViewCell;

@protocol Sample5TableViewCellDelegate <NSObject>

/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapCommentWithPostID:(NSString *)postID;

/**
 *  Good ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapGoodWithPostID:(NSString *)postID;


/**
 *  Restname ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapRestnameWithrestname:(NSString *)restname;

/**
 *  Delete ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)sample5TableViewCell:(Sample5TableViewCell *)cell didTapDeleteWithPostID:(NSString *)postID;
@end

/**
 *  タイムライン画面 TableView の Cell
 */

@interface Sample5TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *RestnameButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (nonatomic,weak) id<Sample5TableViewCellDelegate> delegate;
@property (nonatomic,strong) Profile *comment;

/**
 *  セルの表示の更新
 *
 *  @param profilePost
 */
- (void)configureWithProfilePost:(ProfilePost *)profilePost;


@end
