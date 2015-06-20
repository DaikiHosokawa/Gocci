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

@interface AppDelegate() {
    UITabBarController *tabBarController;
}

@end


@implementation AppDelegate
// !!!:dezamisystem
@synthesize movieData;
@synthesize jsonDic;
@synthesize restrantname;
@synthesize username;
@synthesize userpicture;
@synthesize postFileName;

@synthesize jsonArray;
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
    /*
     [Parse setApplicationId:@"qsmkpvh1AYaZrn1TFstVfe3Mo1llQ9Nfu6NbHcER" clientKey:@"mkjXAp9MVKUvQmRgIm7vZuPYsAtCB2cz9vCJzJve"];
     
     [PFUser enableAutomaticUser];
     
     PFACL *defaultACL = [PFACL ACL];
     
     [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
     
     
     
     // Facebook
     [PFFacebookUtils initializeFacebook];
     
     // Twitter
     [PFTwitterUtils initializeWithConsumerKey:@"co9pGQdqavnWr1lgzBwfvIG6W"
     consumerSecret:@"lgNOyQTEA4AXrxlDsP0diEkmChm5ji2B4QoXwsldpHzI0mfJTg"];
     */
    
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
    UIColor *color_custom = [UIColor colorWithRed:236./255. green:55./255. blue:54./255. alpha:1.];
    
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
    
    /*
     // プッシュ許可の確認を表示
     if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1){
     // iOS8以降
     UIUserNotificationType types =  UIUserNotificationTypeBadge |
     UIUserNotificationTypeSound |
     UIUserNotificationTypeAlert;
     UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
     [application registerUserNotificationSettings:mySettings];
     }else{
     // iOS8以前
     [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
     }
     */
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
    // ここで、例外発生時の情報を出力します。
    // NSLog関数でcallStackSymbolsを出力することで、
    // XCODE上で開発している際にも、役立つスタックトレースを取得できるようになります。
    NSLog(@"%@", exception.name);
    NSLog(@"%@", exception.reason);
    NSLog(@"%@", exception.callStackSymbols);
    
    // ログをUserDefaultsに保存しておく。
    // 次の起動の際に存在チェックすれば、前の起動時に異常終了したことを検知できます。
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
    
    
    NSLog(@"pushInfo in Background: %@", [userInfo description]);
    
    if ( userInfo ) {
        NSNotification *notification = [NSNotification notificationWithName:@"HogeNotification"
                                                                     object:self
                                                                   userInfo:userInfo];
        NSNotificationQueue *queue = [NSNotificationQueue defaultQueue];
        [queue enqueueNotification:notification postingStyle:NSPostWhenIdle];
    }
    
    [self showMessageWithRemoteNotification:userInfo];
    
    // 新着メッセージ数をuserdefaultに格納(アプリを落としても格納されつづける)
    int numberOfNewMessages = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSLog(@"numberOfNewMessages:%d",numberOfNewMessages);
    [ud setInteger:numberOfNewMessages forKey:@"numberOfNewMessages"];
    [ud synchronize];
    
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


@end
