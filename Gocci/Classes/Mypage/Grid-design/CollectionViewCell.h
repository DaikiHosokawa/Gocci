//
//  CollectionViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewController.h"
#import "TimelinePost.h"
#import "Swift.h"

@class CollectionViewController;
@class CollectionViewCell;

@protocol CollectionViewCellDelegate <NSObject>

@optional

- (void)collection:(CollectionViewCell *)cell didTapRestname:(NSString *)rest_id;

- (void)collection:(CollectionViewCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)collection:(CollectionViewCell *)cell didTapThumb:(NSString*)rest_id;
- (void)collection:(CollectionViewCell *)cell didTapLikeButton:(NSString*)postID tapped:(BOOL)tapped;

@end

@interface CollectionViewCell : UICollectionViewCell
{
    int flash_on;
}

@property id supervc;
@property(nonatomic,strong) id<CollectionViewCellDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *option;
@property (weak, nonatomic) IBOutlet SpringButton *likeBtn;


- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;

+ (instancetype)cell;

@end


