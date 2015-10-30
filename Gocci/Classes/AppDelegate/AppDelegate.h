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
//#import <AWSCore/AWSCore.h>
//#import <AWSCognito/AWSCognito.h>
#import "BBBadgeBarButtonItem.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>{
    NSString *restname;
    NSString *rest_id;
    NSString *username;
    NSString *userpicture;
    //初期起動にて緯度経度取得用
    CLLocationManager *locationManager;
    //ライフログ専用日付け保存用
    NSString *lifelogDate;
    
    int cheertag;
    
    //for posting
    //value
    NSString *valueKakaku;
    //hitokoto
    NSString *valueHitokoto;
    //restname
    NSString *stringTenmei;
    NSString *indexTenmei;
    //category
    NSString *stringCategory;
    NSString *indexCategory;
    //EditZone
    NSMutableArray *selectionArray;
    
    BBBadgeBarButtonItem *barButton;
    
    //撮影時保存用
    NSURL *assetURL;
    
    //S3アップロード用
    NSString *accesskey;
    NSString *secretkey;
    NSString *sessionkey;

}

//@property (strong, nonatomic) FBSession *session;
@property (nonatomic, retain) NSString *restname;
@property (nonatomic, retain) NSString *rest_id;
@property(nonatomic) NSString *lifelogDate;
@property (nonatomic, assign) NSInteger screenType;
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) int cheertag;

@property(nonatomic,retain) NSString *valueKakaku;
@property(nonatomic,retain) NSString *stringTenmei;
@property(nonatomic,retain) NSString *indexTenmei;
@property(nonatomic,retain) NSString *indexCategory;
@property(nonatomic,retain) NSString *valueHitokoto;
@property(nonatomic,retain) NSString *stringCategory;
@property(nonatomic,retain) NSMutableArray *selectionArray;

@property(nonatomic, strong) BBBadgeBarButtonItem *barButton;

@property(nonatomic,retain) NSURL *assetURL;

@property(nonatomic,retain) NSString *accesskey;
@property(nonatomic,retain) NSString *secretkey;
@property(nonatomic,retain) NSString *sessionkey;


-(BOOL)isFirstRun;
-(void)checkGPS;

@end
