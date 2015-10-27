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
#import "NearViewController.h"
#import "FollowViewController.h"
#import "RecoViewController.h"

@interface TimelinePageMenuViewController : UIViewController<NearViewControllerDelegate,UIScrollViewDelegate,FollowViewControllerDelegate,RecoViewControllerDelegate>

@property id supervc;

@property (strong, nonatomic) NearViewController *nearViewController;
@property (strong, nonatomic) FollowViewController *followViewController;
@property (strong, nonatomic) RecoViewController *recoViewController;




@end
