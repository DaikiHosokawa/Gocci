//
//  STCustomCollectionViewCell.h
//  UICollectionViewSample
//
//  Created by EIMEI on 2013/06/20.
//  Copyright (c) 2013 stack3.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelinePost.h"

@class NearViewController;
@class NearViewControllerCell;

@protocol NearViewCellDelegate <NSObject>

@optional

- (void)nearViewCell:(NearViewControllerCell *)cell didTapRestname:(NSString *)rest_id;

- (void)nearViewCell:(NearViewControllerCell *)cell didTapOptions:(NSString *)rest_id;

@end

@interface NearViewControllerCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UIImageView *option;

@property (nonatomic,weak) id<NearViewCellDelegate> delegate;

/**
 *  セルの表示の更新
 *
 *  @param timelinePost
 */
- (void)configureWithTimelinePost:(TimelinePost *)timelinePost;

@end
