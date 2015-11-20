//
//  TimelinePageMenuViewController.h
//  Gocci
//
//  Created by INASE on 2015/06/18.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NearViewController.h"
#import "FollowViewController.h"
#import "RecoViewController.h"

#import "SortableTimeLineSubViewProtocol.h"

#import "MoviePlayerManager.h"


@interface TimelinePageMenuViewController : UIViewController<NearViewControllerDelegate,UIScrollViewDelegate,FollowViewControllerDelegate,RecoViewControllerDelegate>

@property id supervc;

@property (strong, nonatomic) NearViewController *nearViewController;
@property (strong, nonatomic) FollowViewController *followViewController;
@property (strong, nonatomic) RecoViewController *recoViewController;

@property (strong, nonatomic) UIViewController *activeSubViewController;

@property (weak, nonatomic) id<SortableTimeLineSubView> currentVisibleSortableSubViewController;


@end
