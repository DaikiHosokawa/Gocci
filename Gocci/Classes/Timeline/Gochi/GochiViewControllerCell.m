//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import "GochiViewControllerCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MoviePlayerManager.h"

@interface GochiViewControllerCell()

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *rest_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *movieURL;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSString *pushed_at;


@end

#define METERS_CUTOFF   1000


@implementation GochiViewControllerCell

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

-(void)configureWithTimelinePost:(TimelinePost_v4 *)timelinePost indexPath:(NSUInteger)indexPath {
    
    self.postID = timelinePost.post_id;
    self.rest_id = timelinePost.rest_id;
    self.user_id = timelinePost.user_id;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:timelinePost.thumbnail]
                      placeholderImage:[UIImage imageNamed:@"dummy.1x1.#EEEEEE"]];
    self.imageView.layer.cornerRadius = 2;
    self.imageView.clipsToBounds = true;
    [self.profileImg sd_setImageWithURL:[NSURL URLWithString:timelinePost.profile_img]
                       placeholderImage:[UIImage imageNamed:@"dummy.1x1.#2F3437"]];
    self.profileImg.layer.cornerRadius = 15;
    self.profileImg.clipsToBounds = true;
    self.title.text = timelinePost.restname;
    self.date.text = timelinePost.post_date;
    self.movieURL = timelinePost.hls_movie;
    self.index = indexPath;
    [self _assignTapAction:@selector(tapRestname:) view:self.title];
    [self _assignTapAction:@selector(tapOption:) view:self.option];
    [self _assignTapAction:@selector(tapThumb:) view:self.imageView];
    [self _assignTapAction:@selector(tapLike:) view:self.likeBtn];
    [self _assignTapAction:@selector(tapImg:) view:self.profileImg];
    
    if (timelinePost.gochi_flag)
    {
        UIImage *img = [UIImage imageNamed:@"Likes_onn.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 1;
    }else{
        UIImage *img = [UIImage imageNamed:@"Likes_off.png"];
        [_likeBtn setBackgroundImage:img forState:UIControlStateNormal];
        flash_on = 0;
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
- (void)tapRestname:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(gochiViewCell:didTapRestname:)]) {
        [self.delegate gochiViewCell:self didTapRestname:self.rest_id];
    }
}

- (void)tapOption:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(gochiViewCell:didTapOptions:post_id:user_id:)]) {
        [self.delegate gochiViewCell:self didTapOptions:self.rest_id post_id:self.postID user_id:self.user_id];
    }
}

- (void)tapThumb:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(gochiViewCell:didTapThumb:)]) {
        [self.delegate gochiViewCell:self didTapThumb:self.rest_id];
        [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:self.movieURL
                                                             size:self.imageView.bounds.size
                                                          atIndex:self.index
                                                       completion:^(BOOL f){
                                                       }];
        [[MoviePlayerManager sharedManager] playMovieAtIndex:self.index inView:self.imageView  frame:self.imageView.frame];
    }
}

- (void)tapImg:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(gochiViewCell:didTapImg:)]) {
        [self.delegate gochiViewCell:self didTapImg:self.user_id];
    }
}

- (NSString *)stringWithDistance:(double)distance {
    BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    NSString *format;
    
    if (isMetric) {
        if (distance < METERS_CUTOFF) {
            format = @"%@ m";
        } else {
            format = @"%@ km";
            distance = distance / 1000;
        }
    }
    
    return [NSString stringWithFormat:format, [self stringWithDouble:distance]];
}

- (NSString *)stringWithDouble:(double)value {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

- (void)tapLike:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(gochiViewCell:didTapLikeButton:tapped:)]) {
        
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
                [self.delegate gochiViewCell:self didTapLikeButton:self.postID tapped:YES];
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
                [self.delegate gochiViewCell:self didTapLikeButton:self.postID tapped:NO];
            });
        }
        
    }
}

@end
