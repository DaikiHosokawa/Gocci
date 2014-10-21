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
#import "Sample2TableViewCell.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate, FBLoginViewDelegate,CLLocationManagerDelegate>
{
    // グローバル変数
    NSString *gText;
    //グローバル変数
    NSString *pID;
    //グローバル変数
    NSURL *postMovieURL;
    //グローバル変数
    NSString *username;
    //グローバル変数
    NSString *userpicture;
    //グローバル変数
    Sample2TableViewCell *cell;
    
    CLLocationManager *locationManager;
    double latitude, longitude; // 取得した緯度経度
    NSString *lat;
    NSString *lon;
    NSString *thumbnailurl;
}
@property (nonatomic, retain) NSString *gText;
@property (nonatomic, retain) NSString *pID;
@property (nonatomic, retain) NSURL *postMovieURL;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *userpicture;
@property (nonatomic) double latitude,longitude;
@property (nonatomic, retain) NSString *thumbnailurl;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lon;
@property (nonatomic) Sample2TableViewCell *cell;

@property (strong, nonatomic) UIWindow *window;

@end
