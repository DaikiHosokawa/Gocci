//
//  STCustomCollectionViewCell.m
//  UICollectionViewSample
//
//  Created by EIMEI on 2013/06/20.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import "NearViewControllerCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MoviePlayerManager.h"

@interface NearViewControllerCell()

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *rest_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *movieURL;
@property (nonatomic) NSUInteger index;


@end


@implementation NearViewControllerCell

+ (instancetype)cell
{
    return [[NSBundle mainBundle] loadNibNamed:@"TimelineCell" owner:self options:nil][0];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self _assignTapAction:@selector(tapRestname:) view:self.title];
        [self _assignTapAction:@selector(tapOption:) view:self.option];
        
    }
    return self;
}

-(void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath {

    self.postID = timelinePost.postID;
    self.rest_id = timelinePost.rest_id;
    self.user_id = timelinePost.userID;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:timelinePost.thumbnail]
                      placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    self.imageView.layer.cornerRadius = 5;
    self.imageView.clipsToBounds = true;
    self.title.text = timelinePost.restname;
    NSString *str1 = [NSString stringWithFormat:@"%@", timelinePost.distance];
    self.distance.text =  [str1 stringByAppendingString:@"m"];
    self.movieURL = timelinePost.movie;
    self.index = indexPath;
    NSLog(@"index:%lu",(unsigned long)self.index);
    [self _assignTapAction:@selector(tapRestname:) view:self.title];
    [self _assignTapAction:@selector(tapOption:) view:self.option];
    [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:self.movieURL
                                                         size:self.imageView.bounds.size
                                                        atIndex:self.index
                                                   completion:^(BOOL f){}];
    [self _assignTapAction:@selector(tapThumb:) view:self.imageView];
}

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
- (void)tapRestname:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(nearViewCell:didTapRestname:)]) {
        [self.delegate nearViewCell:self didTapRestname:self.rest_id];
    }
}

- (void)tapOption:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(nearViewCell:didTapOptions:post_id:user_id:)]) {
        [self.delegate nearViewCell:self didTapOptions:self.rest_id post_id:self.postID user_id:self.user_id];
    }
}

- (void)tapThumb:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(nearViewCell:didTapThumb:)]) {
        [self.delegate nearViewCell:self didTapThumb:self.rest_id];
        [[MoviePlayerManager sharedManager] playMovieAtIndex:self.index inView:self.imageView  frame:self.imageView.frame];
    }
}

@end
