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
//    NSURL *postFileName;	// !!!:dezamisystem
    //グローバル変数
    NSString *username;
    //グローバル変数
    NSString *userpicture;
    
    //緯度経度取得用
    CLLocationManager *locationManager;
    // 取得した緯度経度を保存する変数
    double latitude, longitude;
    // 取得した緯度経度を保存する変数
    NSString *lat;
    NSString *lon;
    //検索画面で使うJSONを保存する変数
    NSDictionary *jsonDic;
    //検索画面から撮影前画面へ
    NSArray *jsonArray;

    NSData *movieData;
    
    NSString *lifelogDate;
}

@property (strong, nonatomic) FBSession *session;
@property (nonatomic, retain) NSString *gText;
@property (nonatomic, retain) NSString *postFileName;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *userpicture;
@property (nonatomic) double latitude,longitude;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *lon;
@property (nonatomic, retain) NSDictionary *jsonDic;
@property (nonatomic, retain) NSData *movieData;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, nonatomic) NSArray *jsonArray;
@property(nonatomic) CLLocationCoordinate2D *coordinate;
@property(nonatomic) NSString *lifelogDate;

-(BOOL)isFirstRun;
-(void)checkGPS;

@end
