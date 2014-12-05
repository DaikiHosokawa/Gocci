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
@class Sample2TableViewCell;

@protocol Sample2TableViewCellDelegate <NSObject>

/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapCommentWithPostID:(NSString *)postID;

/**
 *  Good ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapGoodWithPostID:(NSString *)postID;


/**
 *  Name ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapNameWithusername:(NSString *)username;
- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapNameWithuserspicture:(NSString *)userspicture;


/**
 *  Restname ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
- (void)sample2TableViewCell:(Sample2TableViewCell *)cell didTapRestnameWithrestname:(NSString *)restname;

@end

/**
 *  タイムライン画面 TableView の Cell
 */
@interface Sample2TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *usernameButton;
@property (weak, nonatomic) IBOutlet UIButton *restnameButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

@property (nonatomic,weak) id<Sample2TableViewCellDelegate> delegate;
@property (nonatomic,strong) Timeline *comment;

/**
 *  セルの表示の更新
 *
 *  @param timelinePost 
 */
- (void)configureWithTimelinePost:(TimelinePost *)timelinePost;

@end
