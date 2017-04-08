//
//  FollowListCell.m
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import "FollowListCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface FollowListCell()

@property (nonatomic, strong) NSString *user_id;

@end

@implementation FollowListCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)dealloc
{
    self.UsersPicture = nil;
    self.UsersName = nil;
};


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithFollow:(Follow *)follow indexPath:(NSUInteger)indexPath {
    
    self.user_id = follow.user_id;
    [self.UsersPicture sd_setImageWithURL:[NSURL URLWithString:follow.profile_img]
                         placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    self.imageView.layer.cornerRadius = 2;
    self.imageView.clipsToBounds = true;
    self.UsersName.text = follow.username;
    
    if (follow.follow_flag)
    {
        UIImage *img = [UIImage imageNamed:@"Likes_onn.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 1;
    }else{
        UIImage *img = [UIImage imageNamed:@"Likes_off.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 0;
    }
    
    [self _assignTapAction:@selector(tapLike:) view:self.likeBtn];
    [self _assignTapAction:@selector(tapUsername:) view:self.UsersName];
    [self _assignTapAction:@selector(tapProfile_img:) view:self.UsersPicture];
    
}

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
- (void)tapLike:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(follow:didTapLikeButton:tapped:)]) {
        
        if(flash_on == 0 ){
            flash_on = 1;
            _likeBtn.animation = @"swing";
            _likeBtn.curve = @"easeOut";
            _likeBtn.duration = 1.0;
            _likeBtn.force = 2.0;
            [_likeBtn animate];
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_sync(globalQueue, ^{
                UIImage *img = [UIImage imageNamed:@"Likes_onn.png"];
                [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
                [self.delegate follow:self didTapLikeButton:self.user_id tapped:YES];
            });
        }else{
            flash_on = 0;
            _likeBtn.animation = @"swing";
            _likeBtn.curve = @"easeOut";
            _likeBtn.duration = 1.0;
            _likeBtn.force = 2.0;
            [_likeBtn animate];
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_sync(globalQueue, ^{
                UIImage *img = [UIImage imageNamed:@"Likes_off.png"];
                [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
                [self.delegate follow:self didTapLikeButton:self.user_id tapped:NO];
            });
        }
        
    }
}

- (void)tapUsername:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(follow:didTapUsername:)]) {
        [self.delegate follow:self didTapUsername:self.user_id];
    }
}
- (void)tapProfile_img:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(follow:didTapProfile_img:)]) {
        [self.delegate follow:self didTapProfile_img:self.user_id];
    }
}


@end
