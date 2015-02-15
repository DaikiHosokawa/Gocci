//
//  Sample5TableViewCell.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample5TableViewCell.h"
#import "ProfilePost.h"
#import "APIClient.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Dummy.h"

@interface Sample5TableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *Goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *Commentnum;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UIImageView *starImage;
@property (weak,nonatomic) IBOutlet UILabel *badnum;
@property (weak, nonatomic) IBOutlet UIButton *badBtn;

@property (nonatomic,strong) NSString *postID;
@property (nonatomic,strong) NSString *restname;


@end

@implementation Sample5TableViewCell

#pragma mark - Action

- (IBAction)onCommentButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell:didTapCommentWithPostID:)]) {
        [self.delegate sample5TableViewCell:self didTapCommentWithPostID:self.postID];
    }
}

- (IBAction)onGoodButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell:didTapGoodWithPostID:)]) {
        [self.delegate sample5TableViewCell:self didTapGoodWithPostID:self.postID];
    }
}

- (IBAction)onBadButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell:didTapBadWithPostID:)]) {
        [self.delegate sample5TableViewCell:self didTapBadWithPostID:self.postID];
    }
}


- (IBAction)onRestnameButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell:didTapRestnameWithrestname:)]) {
        [self.delegate sample5TableViewCell:self didTapRestnameWithrestname:self.restname];
    }
}

- (IBAction)onDeleteButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell:didTapDeleteWithPostID:)]) {
        [self.delegate sample5TableViewCell:self didTapDeleteWithPostID:self.postID];
    }
}


#pragma mark - Public Method

- (void)configureWithProfilePost:(ProfilePost *)profilePost
{
    self.postID = profilePost.postID;
    self.restname = profilePost.restname;
    
    // サムネイル画像
    self.thumbnailView.userInteractionEnabled = YES;
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:profilePost.thumbnail]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // 店名
    [self.RestnameButton setTitle:profilePost.restname forState:UIControlStateNormal];
    
    // レート
    if (profilePost.starEvaluation == 1) {
        self.starImage.image = [UIImage imageNamed:@"star_green1.png"];
    } else if (profilePost.starEvaluation == 2) {
        self.starImage.image = [UIImage imageNamed:@"star_green2.png"];
    } else if (profilePost.starEvaluation == 3) {
        self.starImage.image = [UIImage imageNamed:@"star_green3.png"];
    } else if (profilePost.starEvaluation == 4) {
        self.starImage.image = [UIImage imageNamed:@"star_green4.png"];
    } else if (profilePost.starEvaluation == 5) {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    } else {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    }
    
    // Good 数
    self.Goodnum.text = [NSString stringWithFormat:@"%@", @(profilePost.goodNum)];
    // Bad 数
    self.badnum.text = [NSString stringWithFormat:@"%@", @(profilePost.badNum)];
    // コメント数
    self.Commentnum.text = [NSString stringWithFormat:@"%@", @(profilePost.commentNum)];
}

@end
