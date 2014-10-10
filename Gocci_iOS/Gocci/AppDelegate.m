//
//  AppDelegate.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/03.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>


@implementation AppDelegate

@synthesize window = _window;


//facebook認証のcallbackメソッド
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
            withSession:[PFFacebookUtils session]];
            };

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crittercism enableWithAppID: @"540ab4d40729df53fc000003"];
    
    //Parseの初期設定
    [Parse setApplicationId:@"qsmkpvh1AYaZrn1TFstVfe3Mo1llQ9Nfu6NbHcER" clientKey:@"mkjXAp9MVKUvQmRgIm7vZuPYsAtCB2cz9vCJzJve"];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Facebook
    [PFFacebookUtils initializeFacebook];
    
    // Twitter
    [PFTwitterUtils initializeWithConsumerKey:@"co9pGQdqavnWr1lgzBwfvIG6W"
                               consumerSecret:@"lgNOyQTEA4AXrxlDsP0diEkmChm5ji2B4QoXwsldpHzI0mfJTg"];
    
    
    //ナビゲーションバーのアイテムの色を変更
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1.000]];
    
    //ナビゲーションバーの色を変更
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:1.00 green:0.07 blue:0.00 alpha:0.002];
    
    //ナビゲーションバーのタイトルの色を変更
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    // CLLocationManagerのインスタンスを作成
    locationManager = [[CLLocationManager alloc] init];
    // iOS8の対応
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        locationManager.delegate = self;
        // 更新頻度(メートル)
        locationManager.distanceFilter = 20;
        // 取得精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 測位開始
        [locationManager startUpdatingLocation];
        
        // 位置情報測位の許可を求めるメッセージを表示する
        [locationManager requestAlwaysAuthorization]; // 常に許可
        // [self.locationManager requestWhenInUseAuthorization]; // 使用中のみ許可
        
    } else { // iOS7以前
        
        locationManager.delegate = self;
        // 更新頻度(メートル)
        locationManager.distanceFilter = 20;
        // 取得精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 測位開始
        [locationManager startUpdatingLocation];
        
        // 位置測位スタート
        [locationManager startUpdatingLocation];
    }
    

    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    // 位置情報を取り出す
    //緯度
    latitude = newLocation.coordinate.latitude;
    //経度
    longitude = newLocation.coordinate.longitude;
    _lat = [NSString stringWithFormat:@"%f", latitude];
    _lon = [NSString stringWithFormat:@"%f", longitude];
    NSLog(@"lat:%@",_lat);
    NSLog(@"lon:%@",_lon);
    [locationManager stopUpdatingLocation];
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
            [locationManager requestAlwaysAuthorization]; // 常に許可
        }
        
    }
}

-(void) onResume {
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager startUpdatingLocation]; //測位再開
}

-(void) onPause {
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager stopUpdatingLocation]; //測位停止
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    [self onPause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    [self onResume];
    // Facebook
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];

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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
