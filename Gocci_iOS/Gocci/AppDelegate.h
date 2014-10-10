//
//  AppDelegate.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Crittercism.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate, FBLoginViewDelegate,CLLocationManagerDelegate>{
    // グローバル変数
    NSString *gText;
    //グローバル変数
    NSString *pID;
    //グローバル変数
    NSURL *postMovieURL;
    CLLocationManager *locationManager;
    double latitude, longitude; // 取得した緯度経度
    NSString *lat;
    NSString *lon;
}
@property (nonatomic, retain) NSString *gText;
@property (nonatomic, retain) NSString *pID;
@property (nonatomic, retain) NSURL *postMovieURL;
@property (nonatomic) double latitude,longitude;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lon;


@property (strong, nonatomic) UIWindow *window;




@end
