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

@class FolloweeListCell;

@protocol FolloweeListCellDelegate <NSObject>

@optional

- (void)follow:(FolloweeListCell *)cell didTapLikeButton:(NSString*)userID tapped:(BOOL)tapped;
- (void)follow:(FolloweeListCell *)cell didTapUsername:(NSString *)user_id;
- (void)follow:(FolloweeListCell *)cell didTapProfile_img:(NSString*)user_id;

@end

@interface FolloweeListCell : UITableViewCell{
    int flash_on;
}

@property(nonatomic,strong) id<FolloweeListCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *UsersPicture;
@property (weak, nonatomic) IBOutlet UILabel *UsersName;
@property (weak, nonatomic) IBOutlet SpringButton *likeBtn;


- (void)configureWithFollow:(Follow *)follow indexPath:(NSUInteger)indexPath;

+ (instancetype)cell;


@end
