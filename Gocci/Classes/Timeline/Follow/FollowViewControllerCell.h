//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelinePost.h"

@class FollowViewController;
@class FollowViewControllerCell;

@protocol FollowViewCellDelegate <NSObject>

@optional

- (void)followViewCell:(FollowViewControllerCell *)cell didTapRestname:(NSString *)rest_id;

- (void)followViewCell:(FollowViewControllerCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)followViewCell:(FollowViewControllerCell *)cell didTapThumb:(NSString*)rest_id;
- (void)followViewCell:(FollowViewControllerCell *)cell didTapLikeButton:(NSString*)postID;
- (void)followViewCell:(FollowViewControllerCell *)cell didTapImg:(NSString*)user_id;


@end

@interface FollowViewControllerCell : UICollectionViewCell
{
    int flash_on;
}

@property (weak, nonatomic) IBOutlet UIImageView *profileImg;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *option;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;

@property (nonatomic,weak) id<FollowViewCellDelegate> delegate;

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;

+ (instancetype)cell;


@end
