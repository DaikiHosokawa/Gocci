//
//  AppDelegate.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CameraViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, FBLoginViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CameraViewController *viewController;

@end
