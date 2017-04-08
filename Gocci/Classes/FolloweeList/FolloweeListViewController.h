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


@property (nonatomic) NSString *userID;

@end
