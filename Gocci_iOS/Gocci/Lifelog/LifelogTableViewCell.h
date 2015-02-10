//
//  LifelogTableViewCell.h
//  Gocci
//
//  Created by デザミ on 2015/02/01.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LifelogTableViewCell;

@protocol LifelogTableViewCellDelegate <NSObject>

/**
 *  コメントボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
//- (void)sample2TableViewCell:(LifelogTableViewCell *)cell didTapCommentWithPostID:(NSString *)postID;

/**
 *  Good ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
//- (void)sample2TableViewCell:(LifelogTableViewCell *)cell didTapGoodWithPostID:(NSString *)postID;

/**
 *  Bad ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の post_id
 */
//- (void)sample2TableViewCell:(LifelogTableViewCell *)cell didTapBadWithPostID:(NSString *)postID;

/**
 *  Name ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
//- (void)sample2TableViewCell:(LifelogTableViewCell *)cell didTapNameWithusername:(NSString *)username;
//- (void)sample2TableViewCell:(LifelogTableViewCell *)cell didTapNameWithuserspicture:(NSString *)userspicture;

/**
 *  Restname ボタンをタップ
 *
 *  @param cell
 *  @param postID タップした投稿の username
 */
//- (void)sample2TableViewCell:(LifelogTableViewCell *)cell didTapRestnameWithrestname:(NSString *)restname;

@end

#pragma mark - LifelogViewControllerのCell
@interface LifelogTableViewCell : UITableViewCell


@end
