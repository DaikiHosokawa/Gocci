//
//  CollectionViewCell_2.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2015/10/04.
//  Copyright © 2015年 INASE,inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewController_2.h"
#import "TimelinePost.h"

@class CollectionViewController_2;
@class CollectionViewCell_2;

@protocol CollectionViewCell_2Delegate <NSObject>

@optional

- (void)collection:(CollectionViewCell_2 *)cell didTapRestname:(NSString *)rest_id;

- (void)collection:(CollectionViewCell_2 *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)collection:(CollectionViewCell_2 *)cell didTapThumb:(NSString*)rest_id;
- (void)collection:(CollectionViewCell_2 *)cell didTapLikeButton:(NSString*)postID tapped:(BOOL)tapped;

@end

@interface CollectionViewCell_2 : UICollectionViewCell
{
    int flash_on;
}

@property id supervc;
@property(nonatomic,strong) id<CollectionViewCell_2Delegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *option;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;


- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;

+ (instancetype)cell;

@end


