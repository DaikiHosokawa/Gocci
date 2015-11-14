//
//  STCustomCollectionViewCell.m
//  UICollectionViewSample
//
//  Created by EIMEI on 2013/06/20.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import "RecoViewControllerCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MoviePlayerManager.h"

@interface RecoViewControllerCell()

@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *rest_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *movieURL;
@property (nonatomic) NSUInteger index;


@end

#define METERS_CUTOFF   1000


@implementation RecoViewControllerCell

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
    double lat= [timelinePost.distance doubleValue];
    NSString *str1 = [self stringWithDistance:lat];
    self.distance.text = str1;
    self.movieURL = timelinePost.movie;
    self.index = indexPath;
    NSLog(@"index:%lu",(unsigned long)self.index);
    [self _assignTapAction:@selector(tapRestname:) view:self.title];
    [self _assignTapAction:@selector(tapOption:) view:self.option];
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
    if ([self.delegate respondsToSelector:@selector(recoViewCell:didTapRestname:)]) {
        [self.delegate recoViewCell:self didTapRestname:self.rest_id];
    }
}

- (void)tapOption:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(recoViewCell:didTapOptions:post_id:user_id:)]) {
        [self.delegate recoViewCell:self didTapOptions:self.rest_id post_id:self.postID user_id:self.user_id];
    }
}

- (void)tapThumb:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(recoViewCell:didTapThumb:)]) {
        [self.delegate recoViewCell:self didTapThumb:self.rest_id];
        [[MoviePlayerManager sharedManager] addPlayerWithMovieURL:self.movieURL
                                                             size:self.imageView.bounds.size
                                                          atIndex:self.index
                                                       completion:^(BOOL f){
                                                       }];
        [[MoviePlayerManager sharedManager] playMovieAtIndex:self.index inView:self.imageView  frame:self.imageView.frame];
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

// Return a string of the number to one decimal place and with commas & periods based on the locale.
- (NSString *)stringWithDouble:(double)value {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
}

@end