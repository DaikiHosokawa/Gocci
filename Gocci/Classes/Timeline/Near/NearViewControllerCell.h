//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelinePost.h"
#import "Swift.h"

@class NearViewController;
@class NearViewControllerCell;

@protocol NearViewCellDelegate <NSObject>

@optional

- (void)nearViewCell:(NearViewControllerCell *)cell didTapRestname:(NSString *)rest_id;

- (void)nearViewCell:(NearViewControllerCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)nearViewCell:(NearViewControllerCell *)cell didTapThumb:(NSString*)rest_id;
- (void)nearViewCell:(NearViewControllerCell *)cell didTapLikeButton:(NSString*)postID tapped:(BOOL)tapped;
- (void)nearViewCell:(NearViewControllerCell *)cell didTapImg:(NSString*)user_id;

@end

@interface NearViewControllerCell : UICollectionViewCell
{
    int flash_on;
}
@property (weak, nonatomic) IBOutlet UIImageView *profileImg;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIImageView *option;
@property (weak, nonatomic) IBOutlet SpringButton *likeBtn;


@property (nonatomic,weak) id<NearViewCellDelegate> delegate;

- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;

+ (instancetype)cell;


@end
