//
//  TableViewCell.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import "TableViewCell_2.h"
#import "UIView+DropShadow.h"

#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MoviePlayerManager.h"

@interface TableViewCell_2()

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *rest_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *movieURL;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSString *pushed_at;

@end

@implementation TableViewCell_2

- (void)tapRestname:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(table:didTapRestname:)]) {
        [self.delegate table:self didTapRestname:self.rest_id];
    }
}

- (void)tapOption:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(table:didTapOptions:post_id:user_id:)]) {
        [self.delegate table:self didTapOptions:self.rest_id post_id:self.postID user_id:self.user_id];
    }
}

- (void)tapThumb:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(table:didTapThumb:)]) {
        /*
         [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:self.movieURL
         size:self.imageView.bounds.size
         atIndex:self.index
         completion:^(BOOL f){
         }];
         [[MoviePlayerManager sharedManager] playMovieAtIndex:self.index inView:self.imageView  frame:self.imageView.frame];
         */
    }
}

- (void)tapLike:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(table:didTapLikeButton:)]) {
        
        if(flash_on == 0 ){
            UIImage *img = [UIImage imageNamed:@"Likes_onn.png"];
            [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
            flash_on = 1;
            dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_sync(globalQueue, ^{
                [self.delegate table:self didTapLikeButton:self.postID];
            });
        }else{
            
        }
        
    }
}

-(void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath {
    
    self.postID = timelinePost.postID;
    self.rest_id = timelinePost.rest_id;
    self.user_id = timelinePost.userID;
    [self.thumbImageView sd_setImageWithURL:[NSURL URLWithString:timelinePost.thumbnail]
                           placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    self.titleLabel.text = timelinePost.restname;
    self.timeLabel.text = timelinePost.timelabel;
    self.movieURL = timelinePost.movie;
    self.index = indexPath;
    self.pushed_at = timelinePost.pushed_at;
    
    [self _assignTapAction:@selector(tapRestname:) view:self.titleLabel];
    [self _assignTapAction:@selector(tapOption:) view:self.option];
    [self _assignTapAction:@selector(tapThumb:) view:self.thumbImageView];
    
    [self _assignTapAction:@selector(tapLike:) view:self.likeBtn];
    
    
    NSString *string = [NSString stringWithFormat:@"%@", self.pushed_at];
    if ([string isEqualToString:@"0"])
    {
        UIImage *img = [UIImage imageNamed:@"Likes_off.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 0;
        
    }else{
        UIImage *img = [UIImage imageNamed:@"Likes_onn.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 1;
    }
    
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

- (void)awakeFromNib {
}

- (void)dealloc
{
};


@end
