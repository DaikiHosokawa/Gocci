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
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "BBBadgeBarButtonItem.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, FBLoginViewDelegate,CLLocationManagerDelegate>{
    NSString *restname;
    NSString *rest_id;
    NSString *username;
    NSString *userpicture;
    //初期起動にて緯度経度取得用
    CLLocationManager *locationManager;
    //ライフログ専用日付け保存用
    NSString *lifelogDate;
    
    int cheertag;
    
    //価格,コメント,カテゴリー保存用変数
    int valueKakaku;
    NSString *valueHitokoto;
    NSString *stringTenmei;
    NSString *stringFuniki;
    NSString *stringCategory;
    int indexCategory;
    int indexFuniki;
    
    BBBadgeBarButtonItem *barButton;
    
    //撮影時保存用
    NSURL *assetURL;
    //S3アップロード用
    NSString *accesskey;
    NSString *secretkey;
    NSString *sessionkey;

    AWSCognitoCredentialsProvider *cre;
}

@property (strong, nonatomic) FBSession *session;
@property (nonatomic, retain) NSString *restname;
@property (nonatomic, retain) NSString *rest_id;
@property(nonatomic) NSString *lifelogDate;
@property (nonatomic, assign) NSInteger screenType;
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) int cheertag;

@property(nonatomic,assign) int valueKakaku;
@property(nonatomic,retain) NSString *stringTenmei;
@property(nonatomic,assign) int indexCategory;
@property(nonatomic,assign) int indexFuniki;
@property(nonatomic,retain) NSString *valueHitokoto;
@property(nonatomic,retain) NSString *stringFuniki;
@property(nonatomic,retain) NSString *stringCategory;

@property(nonatomic, strong) BBBadgeBarButtonItem *barButton;

@property(nonatomic,retain) NSURL *assetURL;

@property(nonatomic,retain) NSString *accesskey;
@property(nonatomic,retain) NSString *secretkey;
@property(nonatomic,retain) NSString *sessionkey;

@property(nonatomic,retain)AWSCognitoCredentialsProvider *cre;


-(BOOL)isFirstRun;
-(void)checkGPS;

@end
