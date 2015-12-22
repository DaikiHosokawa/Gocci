//
//  AppDelegate.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BBBadgeBarButtonItem.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    NSString *lifelogDate;
    
    
//    BBBadgeBarButtonItem *barButton;
    
}

//@property (nonatomic, retain) NSString *restname;
@property(nonatomic) NSString *lifelogDate;
@property (nonatomic, assign) NSInteger screenType;
@property (strong, nonatomic) UIWindow *window;


//@property(nonatomic, strong) BBBadgeBarButtonItem *barButton;


@end
