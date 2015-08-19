//
//  AppDelegate.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "SCFilterGroup.h"
#import "SCVideoPlayerView.h"
#import <GoogleMaps/GoogleMaps.h>
#import  "TWMessageBarManager.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>

@interface AppDelegate() {
    UITabBarController *tabBarController;
}

@end


@implementation AppDelegate
// !!!:dezamisystem
@synthesize restname;
@synthesize lifelogDate;
@synthesize cheertag;

@synthesize valueKakaku;
@synthesize stringTenmei;
@synthesize indexCategory;
@synthesize indexFuniki;

//@synthesize window = _window;


//facebook認証のcallbackメソッド
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
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
    
    
    [Crittercism enableWithAppID: @"540ab4d40729df53fc000003"];
    
    [GMSServices provideAPIKey:@"AIzaSyDfZOlLwFm0Wv13lNgJF9nsfXlAmUTzHko"];
    //3.5inchと4inchを読み分けする
    CGRect rect = [UIScreen mainScreen].bounds;
    if (rect.size.height == 480) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
        UIViewController* rootViewController = [storyboard instantiateInitialViewController];
        NSLog(@"3.5inch");
        _screenType = 2;
        self.window.rootViewController = rootViewController;
    }
    
    //4.7inch対応
    CGRect rect2 = [UIScreen mainScreen].bounds;
    if (rect2.size.height == 667) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
        UIViewController* rootViewController = [storyboard instantiateInitialViewController];
        NSLog(@"4.7inch");
        _screenType = 3;
        self.window.rootViewController = rootViewController;
    }
    
    //5.5inch対応
    CGRect rect3 = [UIScreen mainScreen].bounds;
    if (rect3.size.height == 736) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
        UIViewController* rootViewController = [storyboard instantiateInitialViewController];
        NSLog(@"5.5inch");
        _screenType = 4;
        self.window.rootViewController = rootViewController;
    }
    
    // !!!:dezamisystem
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    
    //ナビゲーションバーのアイテムの色を変更
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //ナビゲーションバーの色を変更
    [UINavigationBar appearance].barTintColor = color_custom;
    
    //ナビゲーションバーのタイトルの色を変更
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    
    
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
    
    // !!!:dezamisystem・初期化
    {
        indexCategory = -1;
        indexFuniki = -1;
    }
    
    //badge数を解放
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    // エラー追跡用の機能を追加する。
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    [application unregisterForRemoteNotifications];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    [application registerForRemoteNotifications];
    
#else
    UIRemoteNotificationType remoteNotificationType =
    UIRemoteNotificationTypeBadge|
    UIRemoteNotificationTypeSound|
    UIRemoteNotificationTypeAlert|
    UIRemoteNotificationTypeNewsstandContentAvailability;
    [application registerForRemoteNotificationTypes:remoteNotificationType];
#endif
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                    identityPoolId:@"us-east-1:b0252276-27e1-4069-be84-3383d4b3f897"];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1
                                                                         credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelError;
    
    AppDelegate *dele = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [[credentialsProvider getIdentityId] continueWithSuccessBlock:^id(AWSTask *task){
        NSLog(@"identity_id:%@",credentialsProvider.identityId);
        dele.accesskey = credentialsProvider.accessKey;
        dele.secretkey = credentialsProvider.secretKey;
        dele.sessionkey = credentialsProvider.sessionKey;
        NSLog(@"accesskey:%@,secretkey:%@,sessionkey:%@",dele.accesskey,dele.secretkey,dele.sessionkey);
        return nil;
    }];
    
    return YES;
    
    
}

/*
 - (AWSTask *)refresh
 {
 // get Open ID connect Token by the API request to authentication server
 NSURL *url = [NSURL URLWithString:@"YOUR_SERVER_API_URL"];
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
 AWSTaskCompletionSource *source = [AWSTaskCompletionSource taskCompletionSource];
 [NSURLConnection sendAsynchronousRequest:request
 queue:[NSOperationQueue mainQueue]
 completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
 {
 if (data) {
 // retrieve identity ID and Open ID connect Token from the response.
 NSError *jsonError = nil;
 NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
 options:NSJSONReadingMutableLeaves
 error:&jsonError];
 NSLog(@"result: %@", result);
 self.identityId = result[@"identityId"];
 self.token = result[@"token"];
 } else {
 NSLog(@"error: %@", error);
 }
 }];
 }
 
 
 */

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
    
    //badge数を解放
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSLog(@"applicationDidBecomeActive");
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager startUpdatingLocation]; //測位再開
    
    // Facebook
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
    
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
    [self.session close];
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
    [ud setObject:token forKey:@"STRING"];
}

// デバイストークン受信失敗時に呼ばれるメソッド
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //エラー内容をlogに
    NSLog(@"deviceToken error: %@", [error description]);
}

// PUSH通知の受信時に呼ばれるデリゲートメソッド
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"通知受信:%@",userInfo);
    //APNsPHPからuserInfo(message,badge数等)を受け取る
    //log
    NSLog(@"pushInfo: %@", [userInfo description]);
    
    // 新着メッセージ数をuserdefaultに格納(アプリを落としても格納されつづける)
    int numberOfNewMessages = [[[userInfo objectForKey:@"apns"] objectForKey:@"badge"] intValue];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
    [ud synchronize];
}

// BackgroundFetchによってバックグラウンドでPUSH通知を受けたとき呼ばれるデリゲートメソッド

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //APNsPHPからuserInfo(message,badge数等)を受け取る
    NSLog(@"pushInfo in Background: %@", userInfo);
    
    if ( userInfo ) {
        NSNotification *notification = [NSNotification notificationWithName:@"HogeNotification"
                                                                     object:self
                                                                   userInfo:userInfo];
        NSNotificationQueue *queue = [NSNotificationQueue defaultQueue];
        [queue enqueueNotification:notification postingStyle:NSPostWhenIdle];
    }
    
    [self showMessageWithRemoteNotification:userInfo];
    
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
    //ここをログインのところに追加
    // 新着メッセージ数をuserdefaultに格納(アプリを落としても格納されつづける)
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int numberOfNewMessages = (int)[ud integerForKey:@"numberOfNewMessages"]+1;
    NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
    [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = numberOfNewMessages;
    [ud synchronize];
    
}


@end
