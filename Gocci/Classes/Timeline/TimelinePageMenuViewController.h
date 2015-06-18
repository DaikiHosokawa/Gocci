//
//  TimelinePageMenuViewController.h
//  Gocci
//
//  Created by デザミ on 2015/06/18.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NearTimelineTableViewController.h"
#import "FollowTableViewController.h"

@interface TimelinePageMenuViewController : UIViewController<NearTimelineTableViewControllerDelegate,FollowTableViewControllerDelegate>

@end
