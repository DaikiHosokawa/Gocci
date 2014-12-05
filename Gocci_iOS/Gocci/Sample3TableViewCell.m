//
//  Sample3TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/09.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "Sample3TableViewCell.h"
#import "RestaurantPost.h"
#import "APIClient.h"
#import "UIImageView+WebCache.h"
#import <UIImage+Dummy/UIImage+Dummy.h>

@interface  Sample3TableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *RestaurantName;
@property (weak, nonatomic) IBOutlet UILabel *Goodnum;
@property (weak, nonatomic) IBOutlet UIView *contentViewFront;
@property (weak, nonatomic) Sample3TableViewCell *cell;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UILabel *Commentnum;
@property (weak, nonatomic) IBOutlet UIButton *goodBtn;
@property (weak, nonatomic) IBOutlet UIImageView *starImage;


@property (nonatomic,strong) NSString *postID;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *userspicture;

@end

@implementation Sample3TableViewCell

#pragma mark - Action

- (IBAction)onCommentButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample3TableViewCell:didTapCommentWithPostID:)]) {
        [self.delegate sample3TableViewCell:self didTapCommentWithPostID:self.postID];
    }
}

- (IBAction)onGoodButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample3TableViewCell:didTapGoodWithPostID:)]) {
        [self.delegate sample3TableViewCell:self didTapGoodWithPostID:self.postID];
    }
}

- (IBAction)onNameButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample3TableViewCell:didTapNameWithusername:)]) {
         [self.delegate sample3TableViewCell:self didTapNameWithusername:self.username];
    }
}

- (IBAction)onNameButton2:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(sample3TableViewCell:didTapNameWithuserspicture:)]) {
         [self.delegate sample3TableViewCell:self didTapNameWithuserspicture:self.userspicture];
    }
}


#pragma mark - Public Method

- (void)configureWithRestaurantPost:(RestaurantPost *)restaurantPost
{
    self.postID = restaurantPost.postID;
    self.username = restaurantPost.userName;
    self.userspicture = restaurantPost.picture;
    
    // ユーザ画像
    [self.UsersPicture sd_setImageWithURL:[NSURL URLWithString:restaurantPost.picture]
                         placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // ユーザ名
    [self.UsernameButton setTitle:restaurantPost.userName forState:UIControlStateNormal];
    
    // サムネイル画像
    self.thumbnailView.userInteractionEnabled = YES;
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:restaurantPost.thumbnail]
                          placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    
    // 店名
    self.RestaurantName.text = restaurantPost.restname;
    
    // レート
    if (restaurantPost.starEvaluation == 1) {
        self.starImage.image = [UIImage imageNamed:@"star_green1.png"];
    } else if (restaurantPost.starEvaluation == 2) {
        self.starImage.image = [UIImage imageNamed:@"star_green2.png"];
    } else if (restaurantPost.starEvaluation == 3) {
        self.starImage.image = [UIImage imageNamed:@"star_green3.png"];
    } else if (restaurantPost.starEvaluation == 4) {
        self.starImage.image = [UIImage imageNamed:@"star_green4.png"];
    } else if (restaurantPost.starEvaluation == 5) {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    } else {
        self.starImage.image = [UIImage imageNamed:@"star_green5.png"];
    }
    
    // Good 数
    self.Goodnum.text = [NSString stringWithFormat:@"%@", @(restaurantPost.goodNum)];
    
    // コメント数
    self.Commentnum.text = [NSString stringWithFormat:@"%@", @(restaurantPost.commentNum)];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
