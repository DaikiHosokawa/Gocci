//
//  FollowListCell.h
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Swift.h"
#import "Follow.h"

@class FollowListCell;

@protocol FollowListCellDelegate <NSObject>

@optional

- (void)follow:(FollowListCell *)cell didTapLikeButton:(NSString*)userID tapped:(BOOL)tapped;
- (void)follow:(FollowListCell *)cell didTapUsername:(NSString *)user_id;
- (void)follow:(FollowListCell *)cell didTapProfile_img:(NSString*)user_id;

@end

@interface FollowListCell : UITableViewCell{
    int flash_on;
}

@property(nonatomic,strong) id<FollowListCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *UsersName;
@property (weak, nonatomic) IBOutlet SpringButton *likeBtn;


- (void)configureWithFollow:(Follow *)follow indexPath:(NSUInteger)indexPath;

+ (instancetype)cell;

@end
