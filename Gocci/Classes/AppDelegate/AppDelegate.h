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
#import "BBBadgeBarButtonItem.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, FBLoginViewDelegate,CLLocationManagerDelegate>{
    // グローバル変数
    NSString *restrantname;
    //グローバル変数
    NSString *username;
    //グローバル変数
    NSString *userpicture;
    //緯度経度取得用
    CLLocationManager *locationManager;
    //検索画面で使うJSONを保存する変数
    NSDictionary *jsonDic;
    //検索画面から撮影前画面へ
    NSArray *jsonArray;
    
    NSData *movieData;
    
    NSString *lifelogDate;
    
    int cheertag;
    
    
    // !!!:dezamisystem・グローバル変数
    int valueKakaku;
    NSString *valueHitokoto;
    NSString *stringTenmei;
    NSString *stringFuniki;
    NSString *stringCategory;
    int indexCategory;
    int indexFuniki;
    
    BBBadgeBarButtonItem *barButton;
    
    NSURL *assetURL;
}

@property (strong, nonatomic) FBSession *session;
@property (nonatomic, retain) NSString *restrantname;
@property (nonatomic, retain) NSString *postFileName;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *userpicture;
@property (nonatomic, retain) NSDictionary *jsonDic;
@property (nonatomic, retain) NSData *movieData;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, nonatomic) NSArray *jsonArray;
@property(nonatomic) CLLocationCoordinate2D *coordinate;
@property(nonatomic) NSString *lifelogDate;
@property (nonatomic, assign) NSInteger screenType;
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

-(BOOL)isFirstRun;
-(void)checkGPS;

@end
