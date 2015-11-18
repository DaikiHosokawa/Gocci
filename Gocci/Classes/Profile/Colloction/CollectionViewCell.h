//
//  CollectionViewController.h
//  Gocci
//
//  Created by Castela on 2015/10/04.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewController.h"
#import "TimelinePost.h"

@class CollectionViewController;
@class CollectionViewCell;

@protocol CollectionViewCellDelegate <NSObject>

@optional

- (void)collection:(CollectionViewCell *)cell didTapRestname:(NSString *)rest_id;

- (void)collection:(CollectionViewCell *)cell didTapOptions:(NSString *)rest_id post_id:(NSString *)post_id user_id:(NSString *)user_id;

- (void)collection:(CollectionViewCell *)cell didTapThumb:(NSString*)rest_id;
- (void)collection:(CollectionViewCell *)cell didTapLikeButton:(NSString*)postID;

@end

@interface CollectionViewCell : UICollectionViewCell
{
    int flash_on;
}



@property id supervc; //親
@property(nonatomic,strong) id<CollectionViewCellDelegate> delegate;

@property (nonatomic, strong) NSDictionary *receiveDic2;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UIImageView *option;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;


/**
 *  セルの表示の更新
 *
 *  @param timelinePost
 */
- (void)configureWithTimelinePost:(TimelinePost *)timelinePost indexPath:(NSUInteger)indexPath;

/**
 *  TimelineCell を生成
 *
 *  @return
 */
+ (instancetype)cell;

@end


