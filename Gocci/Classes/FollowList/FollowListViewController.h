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

@interface FollowListViewController : UITableViewController
{
    NSString *_postUsername;
}

@property (nonatomic) NSString *postUsername;

@end
