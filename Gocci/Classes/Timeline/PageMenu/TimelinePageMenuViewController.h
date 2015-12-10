//
//  Created by Daiki Hosokawa on 2013/06/20.
//  Copyright (c) 2013 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "NearViewController.h"
#import "FollowViewController.h"
#import "RecoViewController.h"
#import "RequestGPSViewController.h"

#import "SortableTimeLineSubViewProtocol.h"

#import "MoviePlayerManager.h"
#import <CoreLocation/CoreLocation.h>


@interface TimelinePageMenuViewController : UIViewController<NearViewControllerDelegate,UIScrollViewDelegate,FollowViewControllerDelegate,RecoViewControllerDelegate>

@property id supervc;

@property (strong, nonatomic) NearViewController *nearViewController;
@property (strong, nonatomic) FollowViewController *followViewController;
@property (strong, nonatomic) RecoViewController *recoViewController;
@property (strong, nonatomic) RequestGPSViewController *requestGPSViewController;

@property (strong, nonatomic) UIViewController *activeSubViewController;

@property (weak, nonatomic) id<SortableTimeLineSubView> currentVisibleSortableSubViewController;


@end
