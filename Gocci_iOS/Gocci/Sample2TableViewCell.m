//
//  Sample2TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample2TableViewCell.h"
#import "TimelinePost.h"
#import "APIClient.h"
#import "UIImageView+WebCache.h"
#import <UIImage+Dummy/UIImage+Dummy.h>

@interface Sample2TableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UIImageView *usersPicture;
@property (weak, nonatomic) IBOutlet UILabel *review;
@property (weak, nonatomic) IBOutlet UILabel *goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (weak, nonatomic) IBOutlet UILabel *commentnum;
@property (weak, nonatomic) IBOutlet UIImageView *starImage;

@property (nonatomic,strong) NSString *postID;

@end

@implementation Sample2TableViewCell

#pragma mark - Action

- (IBAction)onCommentButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample2TableViewCell:didTapCommentWithPostID:)]) {
        [self.delegate sample2TableViewCell:self didTapCommentWithPostID:self.postID];
    }
}

- (IBAction)onGoodButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample2TableViewCell:didTapGoodWithPostID:)]) {
        [self.delegate sample2TableViewCell:self didTapGoodWithPostID:self.postID];
    }
}


#pragma mark - Public Method

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost
{
    self.postID = timelinePost.postID;
    
    // ユーザ画像
    [self.usersPicture sd_setImageWithURL:[NSURL URLWithString:timelinePost.picture]
                         placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // ユーザ名
    [self.usernameButton setTitle:timelinePost.userName forState:UIControlStateNormal];
    
    // サムネイル画像
    self.thumbnailView.userInteractionEnabled = YES;
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:timelinePost.thumbnail]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // 店名
    [self.restnameButton setTitle:timelinePost.restname forState:UIControlStateNormal];
    
    // レート
    if (timelinePost.starEvaluation == 1) {
        self.starImage.image = [UIImage imageNamed:@"star_green1.png"];
    } else if (timelinePost.starEvaluation == 2) {
        self.starImage.image = [UIImage imageNamed:@"star_green2.png"];
    } else if (timelinePost.starEvaluation == 3) {
        self.starImage.image = [UIImage imageNamed:@"star_green3.png"];
    } else if (timelinePost.starEvaluation == 4) {
        self.starImage.image = [UIImage imageNamed:@"star_green4.png"];
    } else if (timelinePost.starEvaluation == 5) {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    } else {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    }
    
    // Good 数
    self.goodnum.text = [NSString stringWithFormat:@"%@", @(timelinePost.goodNum)];
    
    // コメント数
    self.commentnum.text = [NSString stringWithFormat:@"%@", @(timelinePost.commentNum)];
}

@end
