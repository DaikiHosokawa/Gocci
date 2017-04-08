//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "TimelinePost_v4.h"
#import "Swift.h"

@class GochiViewController;
@class GochiViewControllerCell;

@protocol GochiViewCellDelegate <NSObject>

@optional

- (void)gochiViewCell:(GochiViewControllerCell *)cell didTapRestname:(NSString *)rest_id;

- (void)gochiViewCell:(GochiViewControllerCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)gochiViewCell:(GochiViewControllerCell *)cell didTapThumb:(NSString*)rest_id;
- (void)gochiViewCell:(GochiViewControllerCell *)cell didTapLikeButton:(NSString*)postID tapped:(BOOL)tapped;
- (void)gochiViewCell:(GochiViewControllerCell *)cell didTapImg:(NSString*)user_id;


@end

@interface GochiViewControllerCell : UICollectionViewCell
{
    int flash_on;
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImg;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *option;
@property (weak, nonatomic) IBOutlet SpringButton *likeBtn;

@property (nonatomic,weak) id<GochiViewCellDelegate> delegate;


- (void)configureWithTimelinePost:(TimelinePost_v4 *)timelinePost indexPath:(NSUInteger)indexPath;


+ (instancetype)cell;


@end
