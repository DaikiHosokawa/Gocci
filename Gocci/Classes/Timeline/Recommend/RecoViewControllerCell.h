//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TimelinePost.h"

@class RecoViewController;
@class RecoViewControllerCell;

@protocol RecoViewCellDelegate <NSObject>

@optional

- (void)recoViewCell:(RecoViewControllerCell *)cell didTapRestname:(NSString *)rest_id;

- (void)recoViewCell:(RecoViewControllerCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)recoViewCell:(RecoViewControllerCell *)cell didTapThumb:(NSString*)rest_id;
- (void)recoViewCell:(RecoViewControllerCell *)cell didTapLikeButton:(NSString*)postID;


@end

@interface RecoViewControllerCell : UICollectionViewCell
{
    int flash_on;
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *option;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property (nonatomic,weak) id<RecoViewCellDelegate> delegate;


- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;


+ (instancetype)cell;


@end