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
    
#if defined(START_WITH_DEBUG_SCREEN) && defined(ENTRY_POINT_JUMP)
    storyboard = [UIStoryboard storyboardWithName:Util.getInchString bundle:nil];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:ENTRY_POINT_JUMP];
#elif defined(ENTRY_POINT_JUMP)
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:ENTRY_POINT_JUMP];
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
        //[UITabBar appearance].translucent = YES;
        // 選択時
        [[UITabBar appearance] setTintColor:color_custom];
    }
    
    
    self.window.layer.masksToBounds = YES; // ビューをマスクで切り取る
    self.window.layer.cornerRadius = 4.0; // 角丸マスクを設定(数値は角丸の大きさ)
    

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



// 異常終了を検知した場合に呼び出されるメソッド
void exceptionHandler(NSException *exception) {
    NSLog(@"%@", exception.name);
    NSLog(@"%@", exception.reason);
    NSLog(@"%@", exception.callStackSymbols);
    
    // ログをUserDefaultsに保存しておく。
    NSString *log = [NSString stringWithFormat:@"%@, %@, %@", exception.name, exception.reason, exception.callStackSymbols];
    [[NSUserDefaults standardUserDefaults] setValue:log forKey:@"failLog"];
}

// UIColorから1x1のUIImageを作成
- (UIImage *)imageWithColor:(UIColor *)color
{
    UIView *__view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 1.0f, 1.0f)];
    __view.backgroundColor = color;
    UIGraphicsBeginImageContext(__view.frame.size);
    CGContextRef __context = UIGraphicsGetCurrentContext();
    [__view.layer renderInContext: __context];
    UIImage *__image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return __image;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
#if !(TARGET_IPHONE_SIMULATOR)
    //badge数を解放
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#endif
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}


- (void)applicationWillTerminate:(UIApplication *)application
{
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
