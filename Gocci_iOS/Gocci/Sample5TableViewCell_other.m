//
//  Sample5TableViewCell_other.m
//  Gocci
//
//  Created by Ometeotl on 2014/10/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample5TableViewCell_other.h"
#import "Profile_otherPost.h"
#import "APIClient.h"
#import "UIImageView+WebCache.h"
#import <UIImage+Dummy/UIImage+Dummy.h>

@interface Sample5TableViewCell_other()

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UILabel *goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) IBOutlet UILabel *commentnum;
@property (weak, nonatomic) IBOutlet UIImageView *starImage;
@property (weak,nonatomic) IBOutlet UILabel *badnum;
@property (weak, nonatomic) IBOutlet UIButton *badBtn;


@property (nonatomic,strong) NSString *postID;
@property (nonatomic,strong) NSString *restname;

@end

@implementation Sample5TableViewCell_other

- (IBAction)onCommentButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell_other:didTapCommentWithPostID:)]) {
        [self.delegate sample5TableViewCell_other:self didTapCommentWithPostID:self.postID];
    }
}

- (IBAction)onGoodButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell_other:didTapGoodWithPostID:)]) {
        [self.delegate sample5TableViewCell_other:self didTapGoodWithPostID:self.postID];
    }
}

- (IBAction)onBadButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell_other:didTapBadWithPostID:)]) {
        [self.delegate sample5TableViewCell_other:self didTapBadWithPostID:self.postID];
    }
}


- (IBAction)onRestnameButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample5TableViewCell_other:didTapRestnameWithrestname:)]) {
        [self.delegate sample5TableViewCell_other:self didTapRestnameWithrestname:self.restname];
    }
}


#pragma mark - Public Method

- (void)configureWithProfile_otherPost:(Profile_otherPost *)profile_otherPost
{
    self.postID = profile_otherPost.postID;
     self.restname = profile_otherPost.restname;
    
    
    // サムネイル画像
    self.thumbnailView.userInteractionEnabled = YES;
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:profile_otherPost.thumbnail]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // 店名
    [self.restnameButton setTitle:profile_otherPost.restname forState:UIControlStateNormal];
    
    // レート
    if (profile_otherPost.starEvaluation == 1) {
        self.starImage.image = [UIImage imageNamed:@"star_green1.png"];
    } else if (profile_otherPost.starEvaluation == 2) {
        self.starImage.image = [UIImage imageNamed:@"star_green2.png"];
    } else if (profile_otherPost.starEvaluation == 3) {
        self.starImage.image = [UIImage imageNamed:@"star_green3.png"];
    } else if (profile_otherPost.starEvaluation == 4) {
        self.starImage.image = [UIImage imageNamed:@"star_green4.png"];
    } else if (profile_otherPost.starEvaluation == 5) {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    } else {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    }
    
    // Good 数
    self.goodnum.text = [NSString stringWithFormat:@"%@", @(profile_otherPost.goodNum)];
   
    // Bad 数
    self.badnum.text = [NSString stringWithFormat:@"%@", @(profile_otherPost.badNum)];
    
    // コメント数
    self.commentnum.text = [NSString stringWithFormat:@"%@", @(profile_otherPost.commentNum)];
}
@end
