//
//  Sample2TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "TimelineCell.h"
#import "TimelinePost.h"
#import "UIView+DropShadow.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Dummy.h"

NSString * const TimelineCellIdentifier = @"TimelineCell";

@interface TimelineCell()

@property (nonatomic,weak) IBOutlet UIView *background;
@property (nonatomic,weak) IBOutlet UIImageView *avaterImageView;
@property (nonatomic,weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet UILabel *commentLabel;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *commentHeightConstraint;

@property (nonatomic,strong) NSString *postID;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *userspicture;
@property (nonatomic,strong) NSString *restname;


@end

@implementation TimelineCell

#pragma mark - Initialize

+ (instancetype)cell
{
    return [[NSBundle mainBundle] loadNibNamed:@"TimelineCell" owner:self options:nil][0];
}


#pragma mark - Action

- (void)tapNameLabel:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapNameWithUserName:)]) {
        [self.delegate timelineCell:self didTapNameWithUserName:self.username];
    }
}

- (void)tapAvaterImageView:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapNameWithUserPicture:)]) {
        [self.delegate timelineCell:self didTapNameWithUserPicture:self.userspicture];
    }
}


#pragma mark - Public Method

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost
{
    [self.background dropShadow];
    
    self.postID = timelinePost.postID;
    self.username = timelinePost.userName;
    self.userspicture = timelinePost.picture;
    self.restname = timelinePost.restname;
    
    // ユーザアイコンを円形に
    self.avaterImageView.layer.cornerRadius = self.avaterImageView.frame.size.width / 2.0;
    self.avaterImageView.clipsToBounds = YES;
    
    // ユーザ画像
    [self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:timelinePost.picture]
                            placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // ユーザ名
    self.userNameLabel.text = timelinePost.userName;
    
    // TODO: 時間
    self.timeLabel.text = nil;
    
    // サムネイル画像
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:timelinePost.thumbnail]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // コメント
    self.commentLabel.text = timelinePost.comment;
    
    // コメントに合わせてセルの高さを調整
    [self.commentLabel sizeToFit];
    self.commentHeightConstraint.constant = self.commentLabel.frame.size.height;
    
    CGFloat height = 0.0;
    height += self.commentLabel.frame.origin.y;
    height += self.commentLabel.frame.size.height;
    height += 20;
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    // ユーザ名タップイベント
    for (UIGestureRecognizer *recognizer in self.userNameLabel.gestureRecognizers) {
        [self.userNameLabel removeGestureRecognizer:recognizer];
    }
    UITapGestureRecognizer *tapName = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(tapNameLabel:)];
    self.userNameLabel.userInteractionEnabled = YES;
    [self.userNameLabel addGestureRecognizer:tapName];
    
    // ユーザアイコンタップイベント
    for (UIGestureRecognizer *recognizer in self.avaterImageView.gestureRecognizers) {
        [self.avaterImageView removeGestureRecognizer:recognizer];
    }
    UITapGestureRecognizer *tapAvater = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tapAvaterImageView:)];
    self.avaterImageView.userInteractionEnabled = YES;
    [self.avaterImageView addGestureRecognizer:tapAvater];
}

+ (CGFloat)cellHeightWithTimelinePost:(TimelinePost *)post
{
    TimelineCell *cell = [TimelineCell cell];
    [cell configureWithTimelinePost:post];
    
    return cell.frame.size.height;
}

@end
