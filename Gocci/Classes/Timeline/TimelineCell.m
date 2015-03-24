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

#define THUMBNAIL_VIEW_MARGIN 8.0

NSString * const TimelineCellIdentifier = @"TimelineCell";

@interface TimelineCell()

@property (nonatomic, weak) IBOutlet UIView *background;
@property (nonatomic, weak) IBOutlet UIImageView *avaterImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) IBOutlet UIView *restaurantView;
@property (nonatomic, weak) IBOutlet UIImageView *restaurantImageView;
@property (nonatomic, weak) IBOutlet UILabel *restaurantNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *restaurantAddressLabel;

@property (nonatomic, weak) IBOutlet UIView *likeView;
@property (nonatomic, weak) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cheerView;

@property (nonatomic, weak) IBOutlet UIView *commentView;
@property (nonatomic, weak) IBOutlet UILabel *commentCountLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *thumbnailViewHeightConstraint;

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userspicture;
@property (nonatomic, strong) NSString *restname;
@property (nonatomic, strong) NSString *locality;
@property (nonatomic, strong) NSString *tell;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *homepage;


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
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapNameWithUserName:picture:)]) {
        [self.delegate timelineCell:self didTapNameWithUserName:self.username picture:_userspicture];
    }
}

- (void)tapAvaterImageView:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapNameWithUserPicture:name:)]) {
        [self.delegate timelineCell:self didTapNameWithUserPicture:self.userspicture name:_username];
    }
}

- (void)tapRestautant:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapRestaurant:locality:tel:homepage:category:)]) {
        [self.delegate timelineCell:self didTapRestaurant:self.restname locality:self.locality tel:self.tell homepage:self.homepage category:self.category];
    }
}

- (void)tapLike:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapLikeButtonWithPostID:)]) {
        [self.delegate timelineCell:self didTapLikeButtonWithPostID:self.postID];
    }
}

- (void)tapComment:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapCommentButtonWithPostID:)]) {
        [self.delegate timelineCell:self didTapCommentButtonWithPostID:self.postID];
    }
}

- (void)tapViolate:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapViolateButtonWithPostID:)]) {
        [self.delegate timelineCell:self didTapViolateButtonWithPostID:self.postID];
    }
}

- (void)onDeleteButton:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(timelineCell:didTapDeleteWithPostID:)]) {
        [self.delegate timelineCell:self didTapDeleteWithPostID:self.postID];
    }
}

#pragma mark - Public Method

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost
{
    [self.background dropShadow];
    [self.restaurantView dropShadowLight];
    
    self.postID = timelinePost.postID;
    self.username = timelinePost.userName;
    self.userspicture = timelinePost.picture;
    self.restname = timelinePost.restname;
    self.locality = timelinePost.locality;
    self.homepage = timelinePost.homepage;
    self.tell = timelinePost.tel;
    self.category = timelinePost.category;
    
    // ユーザアイコンを円形に
    self.avaterImageView.layer.cornerRadius = self.avaterImageView.frame.size.width / 2.0;
    self.avaterImageView.clipsToBounds = YES;
    
    // 動画サムネイルのサイズ調整
    // 一辺の長さが (画面の横幅 - マージン) の正方形とする
    CGFloat thumbnailWidth = [UIScreen mainScreen].bounds.size.width - (THUMBNAIL_VIEW_MARGIN * 2);
    self.thumbnailViewWidthConstraint.constant = thumbnailWidth;
    self.thumbnailViewHeightConstraint.constant = thumbnailWidth;
    self.thumbnailView.frame = CGRectMake(THUMBNAIL_VIEW_MARGIN,
                                          self.thumbnailView.frame.origin.y,
                                          thumbnailWidth, thumbnailWidth);
    
    // ユーザ画像
    [self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:timelinePost.picture]
                            placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // ユーザ名
    self.userNameLabel.text = timelinePost.userName;
    
    // TODO: 時間
    self.timeLabel.text = timelinePost.timelabel;
    
    // サムネイル画像
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:timelinePost.thumbnail]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // TODO: 店舗サムネイル画像
    self.restaurantImageView.image = [UIImage imageNamed:@"ic_userpicture.png"];
    
    // 店舗名
    self.restaurantNameLabel.text = timelinePost.restname;
    
    // 店舗住所
    self.restaurantAddressLabel.text = timelinePost.locality;
    
    // Like 数
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", @(timelinePost.goodNum)];
    
    // Comment 数
    self.commentCountLabel.text = [NSString stringWithFormat:@"%@", @(timelinePost.commentNum)];
    
    /*
    //応援画像
    if(timelinePost.commentNum == 1){
        self.cheerView.image
    }else if(timelinePost.commentNum == 2){
        self.cheerView.image
    }else if(timelinePost.commentNum == 3) {
        self.cheerView.image
     }else if(timelinePost.commentNum == 3) {
     self.cheerView.image
     }
     */
    
    self.cheerView.image = [UIImage imageNamed:@"ic_userpicture.png"];
    
    // タップイベント
    [self _assignTapAction:@selector(tapNameLabel:) view:self.userNameLabel];
    [self _assignTapAction:@selector(tapAvaterImageView:) view:self.avaterImageView];
    [self _assignTapAction:@selector(tapRestautant:) view:self.restaurantView];
    [self _assignTapAction:@selector(tapLike:) view:self.likeView];
    [self _assignTapAction:@selector(tapComment:) view:self.commentView];
   [self _assignTapAction:@selector(tapViolate:) view:self.ViolateView];
}

+ (CGFloat)cellHeightWithTimelinePost:(TimelinePost *)post
{
    TimelineCell *cell = [TimelineCell cell];
    [cell configureWithTimelinePost:post];
    
    return cell.thumbnailViewTopConstraint.constant + cell.thumbnailView.frame.size.height + cell.thumbnailViewBottomConstraint.constant;
}


#pragma mark - Private Methods

/**
 *  View にタップイベントを設定
 *
 *  @param selector タップイベント時に呼び出されるメソッド
 *  @param view     設定先の View
 */
- (void)_assignTapAction:(SEL)selector view:(UIView *)view
{
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        [view removeGestureRecognizer:recognizer];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:selector];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
}

@end
