//
//  FollowListViewController.h
//  Gocci
//
//  Created by Castela on 2015/05/05.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheerListCell.h"
#import <Foundation/Foundation.h>

@interface CheerListViewController : UITableViewController
{
    NSString *_postRestID;
}

@property (nonatomic) NSString *postRestID;
@property (nonatomic) NSString *userID;

@end
