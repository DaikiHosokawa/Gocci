//
//  TimelinePageMenuViewController.h
//  Gocci
//
//  Created by INASE on 2015/06/18.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AllTimelineTableViewController.h"
#import "FollowTableViewController.h"

@interface TimelinePageMenuViewController : UIViewController<AllTimelineTableViewControllerDelegate,FollowTableViewControllerDelegate>

@property id supervc;

@end
