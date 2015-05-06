//
//  FollowListViewController.h
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolloweeListCell.h"
#import <Foundation/Foundation.h>

@interface FolloweeListViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>

{
    NSString *_postUsername;
    NSString *_postUsername_with_profile2;
    NSString *_postUserPicture_with_profile2;

}

@property (nonatomic) NSString *postUsername;
@property (nonatomic) NSString *postUsername_with_profile2;
@property (nonatomic) NSString *postUserPicture_with_profile2;


@end
