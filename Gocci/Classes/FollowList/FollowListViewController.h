//
//  FollowListViewController.h
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowListCell.h"
#import <Foundation/Foundation.h>

@interface FollowListViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSString *_postUsername;
    NSString *_postUsername_with_profile;
    NSString *_postUserPicture_with_profile;
    NSString *_postUserFlag_with_profile;

}

@property (nonatomic) NSString *postUsername;
@property (nonatomic) NSString *postUsername_with_profile;
@property (nonatomic) NSString *userID;

@end
