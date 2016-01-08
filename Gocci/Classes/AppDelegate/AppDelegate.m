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
#import <GoogleMaps/GoogleMaps.h>
#import  "TWMessageBarManager.h"
#import <AWSS3/AWSS3.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "SVProgressHUD.h"

#import "Swift.h"

@interface AppDelegate() {
    UITabBarController *tabBarController;
}

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // エラー追跡用の機能を追加する。
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    //[Debug afterAppLaunch];
    
    // prebuffer persistent data
    [Persistent setupAndCacheAllDataFromDisk];
    
    // Conversion from userdef stored identity_id to keychain stored identity_id
    if ([Persistent identity_id] == nil && [Util getUserDefString:@"identity_id"] != nil) {
        NSLog(@"conversation from version 1.2.7? to 2.0.0 happend");
        Persistent.identity_id = [Util getUserDefString:@"identity_id"];
        
        [Permission conversationFromPrevieousVersion];
    }
    
    // Start network monitoring for network state availibility
    [Network startNetworkStatusMonitoring];
    
    // Handle bg task in the scheduler.
    [TaskSchedulerWrapper start];
    
    // No default storyboard anymore = we need to setup the window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
#ifdef FRESH_START
    [Persistent resetPersistentDataToInitialState];
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
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
   
    [UINavigationBar appearance].barTintColor = color_custom;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes
    = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
   
    [UINavigationBar appearance].translucent = NO;
    // !!!:dezamisystem・タブバー設定
    {
        //UIColor *color_selected = [UIColor colorWithRed:245./255. green:43./255. blue:0. alpha:1.];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
        //タブ選択時のフォントとカラー
        UIColor *colorSelected = color_custom;
        NSDictionary *selectedAttributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorSelected};
        [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
        //通常時のフォントとカラー
        UIColor *colorNormal = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        NSDictionary *attributesNormal = @{NSFontAttributeName : font, NSForegroundColorAttributeName : colorNormal};
        [[UITabBarItem appearance] setTitleTextAttributes:attributesNormal forState:UIControlStateNormal];
        
        //背景色
        [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
        [UITabBar appearance].translucent = NO;
        // 選択時
        [[UITabBar appearance] setTintColor:color_custom];
    }
    
    
    self.window.layer.masksToBounds = YES; // ビューをマスクで切り取る
    self.window.layer.cornerRadius = 4.0; // 角丸マスクを設定(数値は角丸の大きさ)
    
    return YES;
}

// 異常終了を検知した場合に呼び出されるメソッド
void exceptionHandler(NSException *exception) {
    NSLog(@"%@", exception.name);
    NSLog(@"%@", exception.reason);
    NSLog(@"%@", exception.callStackSymbols);
    
    // TODO send this data to a logging server
    
    /* swift version
     NSSetUncaughtExceptionHandler { exception in
     print(exception)
     print(exception.callStackSymbols)
     }
     */
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Tell the scheduler to check for tasks. The app became active again,
    // so maybe this is a good time to upload heavy stuff again.
    [TaskSchedulerWrapper nudge];
    
    // when the user comes back from the settings screen TODO UNTESTED
    [Permission requestPushNotificationPermissionOnlyIfTheUserWantsThem];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Tell the scheduler to check for tasks. The app will enter bg
    // so maybe this is a good time to upload heavy stuff that failed erlier.
    [TaskSchedulerWrapper nudge];
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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [Permission deviceTokenRecived:deviceToken.description];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [Permission didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [Permission didRegisterUserNotificationSettings:notificationSettings];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
//    NSLog(@"######   didReceiveRemoteNotification.  %@",  userInfo);
    
    [Permission recievedRemoteNotification:userInfo];
    
    //Background Modeをonにすれば定期的に通知内容を取りに行く
    completionHandler(UIBackgroundFetchResultNoData);
}




- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
    /* Store the completion handler.*/
    [AWSS3TransferUtility interceptApplication:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}


@end
