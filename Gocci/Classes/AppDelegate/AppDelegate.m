//
//  AppDelegate.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "const.h"
#import "util.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import  "TWMessageBarManager.h"
#import <AWSS3/AWSS3.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "FHSTwitterEngine.h"

#import "Swift.h"

@interface AppDelegate() {
    UITabBarController *tabBarController;
}

@end


@implementation AppDelegate


@synthesize restname;
@synthesize lifelogDate;
@synthesize cheertag;

@synthesize valueKakaku;
@synthesize stringTenmei;
@synthesize indexCategory;

//@synthesize window = _window;

/*
//facebook認証のcallbackメソッド
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}*/

// Facebook SDK needs this
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate"];
    
    // 保存
    [userDefaults synchronize];
    
    // 初回起動
    return YES;
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // No default storyboard anymore = we need to setup the window 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    [FBSDKSettings setAppID:FACEBOOK_APP_ID];
    
    
#ifdef FRESH_START
    [Util removeAccountSpecificDataFromUserDefaults];
#endif
    
#ifndef INDEVEL
    [Crittercism enableWithAppID: CRITTERCISM_APP_ID];
#endif
    
#ifndef STRIPPED
    [GMSServices provideAPIKey: GOOGLE_MAP_SERVICE_API_KEY];
#endif
    
#if defined(START_WITH_DEBUG_SCREEN) || defined(STRIPPED)
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Debug" bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
#else
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:Util.getInchString bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
#endif
    
    // !!!:dezamisystem
    
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    
    [UINavigationBar appearance].barTintColor = color_custom;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes
    = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // !!!:dezamisystem・タブバー設定
    {
        //UIColor *color_selected = [UIColor colorWithRed:245./255. green:43./255. blue:0. alpha:1.];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
        //タブ選択時のフォントとカラー
        UIColor *colorSelected = color_custom; //[UIColor colorWithRed:0.9607843137254902 green:0.16862745098039217 blue:0.00 alpha:1.0];
        NSDictionary *selectedAttributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorSelected};
        [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        //通常時のフォントとカラー
        UIColor *colorNormal = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        NSDictionary *attributesNormal = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorNormal};
        [[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
        
        //背景色
        [UITabBar appearance].backgroundImage = [UIImage imageNamed:@"barTint"];
        [UITabBar appearance].translucent = NO;
        // 選択時
        [[UITabBar appearance] setTintColor:color_custom];
    }
    
    
    self.window.layer.masksToBounds = YES; // ビューをマスクで切り取る
    self.window.layer.cornerRadius = 4.0; // 角丸マスクを設定(数値は角丸の大きさ)
    
    // !!!:dezamisystem・初期化
    {
        //indexCategory = -1;
        //indexFuniki = -1;
    }
    
#if !(TARGET_IPHONE_SIMULATOR)
    //badge数を解放
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#endif
    
    // エラー追跡用の機能を追加する。
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    [application unregisterForRemoteNotifications];
    
#if !(TARGET_IPHONE_SIMULATOR)
    //メソッドの有無でOSを判別
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        
        //iOS8
        //デバイストークの取得
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        //許可アラートの表示
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        
        //iOS7
        UIRemoteNotificationType types =UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
#endif
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    
    return YES;
}



-(void)checkGPS{
    
    NSLog(@"open checkGPS");
    // CLLocationManagerのインスタンスを作成
    locationManager = [[CLLocationManager alloc] init];
    // デリゲートを設定
    locationManager.delegate = self;
    // 更新頻度(メートル)
    locationManager.distanceFilter = 100;
    // 取得精度
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // iOS8の対応
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8以降
        // 位置情報測位の許可を求めるメッセージを表示する
        [locationManager requestWhenInUseAuthorization]; // 使用中だけ
        
    } else { // iOS7以前
        // 測位開始
        [locationManager startUpdatingLocation];
    }
}

// 異常終了を検知した場合に呼び出されるメソッド
void exceptionHandler(NSException *exception) {
    NSLog(@"%@", exception.name);
    NSLog(@"%@", exception.reason);
    NSLog(@"%@", exception.callStackSymbols);
    
    // ログをUserDefaultsに保存しておく。
    NSString *log = [NSString stringWithFormat:@"%@, %@, %@", exception.name, exception.reason, exception.callStackSymbols];
    [[NSUserDefaults standardUserDefaults] setValue:log forKey:@"failLog"];
}




- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{//iOS8対応
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        // 位置測位スタート
        [locationManager startUpdatingLocation];
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            // ユーザが位置情報の使用を許可していない
            [locationManager requestWhenInUseAuthorization]; // 常に許可
            
        }
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager stopUpdatingLocation]; //測位停止
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    
#if !(TARGET_IPHONE_SIMULATOR)
    //badge数を解放
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#endif
    
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager startUpdatingLocation]; //測位再開
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Facebook
//    [FBAppEvents activateApp];
//    [FBAppCall handleDidBecomeActiveWithSession:self.session];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    //[self.session close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//APNsサーバーよりデバイストークン受信成功したときに呼ばれるメソッド
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *token = deviceToken.description;
    
    //deveceTokenから"<"と">"を消す
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //このトークンをサーバ側で管理する。取り合えず、ログで出す
    NSLog(@"deviceToken: %@", token);
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:token forKey:@"register_id"];
}

// デバイストークン受信失敗時に呼ばれるメソッド
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //エラー内容をlogに
    NSLog(@"deviceToken error: %@", [error description]);
}

//Before iOS6 call this method
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // 新着メッセージ数をuserdefaultに格納(アプリを落としても格納されつづける)
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int numberOfNewMessages = (int)[ud integerForKey:@"numberOfNewMessages"]+1;
    NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
    [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
    application.applicationIconBadgeNumber = numberOfNewMessages;
    [ud synchronize];
    
    // App in background & active from push notice
    if (application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"receeive notice background");
    }
    // アプリが起動中のときにプッシュ通知を受信した場合
    else{
        NSLog(@"receeive notice foreground");
        [self showMessageWithRemoteNotification:userInfo];
    }

}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

//After iOS7 call this method
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"userinfo:%@",userInfo);
    
    if ( userInfo ) {
        NSNotification *notification = [NSNotification notificationWithName:@"HogeNotification"
                                                                     object:self
                                                                   userInfo:userInfo];
        NSNotificationQueue *queue = [NSNotificationQueue defaultQueue];
        [queue enqueueNotification:notification postingStyle:NSPostWhenIdle];
    
        [self showMessageWithRemoteNotification:userInfo];
        // 新着メッセージ数をuserdefaultに格納(アプリを落としても格納されつづける)
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        int numberOfNewMessages = (int)[ud integerForKey:@"numberOfNewMessages"]+1;
        NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
        [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
        application.applicationIconBadgeNumber = numberOfNewMessages;
        [ud synchronize];
    }
    
    
    //Background Modeをonにすれば定期的に通知内容を取りに行く
    completionHandler(UIBackgroundFetchResultNoData);
}


- (void) showMessageWithRemoteNotification:(NSDictionary *)userInfo {
    
    // [TWMessageBarManager sharedInstance];
    
    NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"お知らせ"
                                                   description:message
                                                          type:TWMessageBarMessageTypeSuccess
                                                      duration:4.0];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
    /* Store the completion handler.*/
    [AWSS3TransferUtility interceptApplication:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}


@end
