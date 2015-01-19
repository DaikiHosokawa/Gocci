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
#import "SCFilterGroup.h"
#import "SCVideoPlayerView.h"



@implementation AppDelegate



//@synthesize window = _window;


//facebook認証のcallbackメソッド
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
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
{/*
    if ([self isFirstRun]) {
        
        // 初回起動時の処理を書く
        NSLog(@"初回起動だよ");
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        // Init the pages texts, and pictures.
        ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithTitle:@"Picture 1"
                                                                subTitle:@"Champs-Elysées by night"
                                                             pictureName:@"tutorial_background_00@2x.jpg"
                                                                duration:3.0];
        ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithTitle:@"Picture 2"
                                                                subTitle:@"The Eiffel Tower with\n cloudy weather"
                                                             pictureName:@"tutorial_background_01@2x.jpg"
                                                                duration:3.0];
        ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithTitle:@"Picture 3"
                                                                subTitle:@"An other famous street of Paris"
                                                             pictureName:@"tutorial_background_02@2x.jpg"
                                                                duration:3.0];
        ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithTitle:@"Picture 4"
                                                                subTitle:@"The Eiffel Tower with a better weather"
                                                             pictureName:@"tutorial_background_03@2x.jpg"
                                                                duration:3.0];
        ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithTitle:@"Picture 5"
                                                                subTitle:@"The Louvre's Museum Pyramide"
                                                             pictureName:@"tutorial_background_04@2x.jpg"
                                                                duration:3.0];
        NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
        
        // Set the common style for the title.
        ICETutorialLabelStyle *titleStyle = [[ICETutorialLabelStyle alloc] init];
        [titleStyle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
        [titleStyle setTextColor:[UIColor whiteColor]];
        [titleStyle setLinesNumber:1];
        [titleStyle setOffset:180];
        [[ICETutorialStyle sharedInstance] setTitleStyle:titleStyle];
        
        // Set the subTitles style with few properties and let the others by default.
        [[ICETutorialStyle sharedInstance] setSubTitleColor:[UIColor whiteColor]];
        [[ICETutorialStyle sharedInstance] setSubTitleOffset:150];
        
        // Init tutorial.
        self.viewController = [[ICETutorialController alloc] initWithPages:tutorialLayers
                                                                  delegate:self];
        
        // Run it.
        [self.viewController startScrolling];
        
        self.window.rootViewController = self.viewController;
        [self.window makeKeyAndVisible];
        
        [Crittercism enableWithAppID: @"540ab4d40729df53fc000003"];
        
        [Parse setApplicationId:@"qsmkpvh1AYaZrn1TFstVfe3Mo1llQ9Nfu6NbHcER" clientKey:@"mkjXAp9MVKUvQmRgIm7vZuPYsAtCB2cz9vCJzJve"];
        
        [PFUser enableAutomaticUser];
        
        PFACL *defaultACL = [PFACL ACL];
        
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
        
        
        // Facebook
        [PFFacebookUtils initializeFacebook];
        
        // Twitter
        [PFTwitterUtils initializeWithConsumerKey:@"co9pGQdqavnWr1lgzBwfvIG6W"
                                   consumerSecret:@"lgNOyQTEA4AXrxlDsP0diEkmChm5ji2B4QoXwsldpHzI0mfJTg"];
        
        return YES;

    }else{
*/
    [Crittercism enableWithAppID: @"540ab4d40729df53fc000003"];
    
    [Parse setApplicationId:@"qsmkpvh1AYaZrn1TFstVfe3Mo1llQ9Nfu6NbHcER" clientKey:@"mkjXAp9MVKUvQmRgIm7vZuPYsAtCB2cz9vCJzJve"];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    // Facebook
    [PFFacebookUtils initializeFacebook];
    
    // Twitter
    [PFTwitterUtils initializeWithConsumerKey:@"co9pGQdqavnWr1lgzBwfvIG6W"
                               consumerSecret:@"lgNOyQTEA4AXrxlDsP0diEkmChm5ji2B4QoXwsldpHzI0mfJTg"];
    
    //3.5inchと4inchを読み分けする
    CGRect rect = [UIScreen mainScreen].bounds;
    if (rect.size.height == 480) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
        UIViewController* rootViewController = [storyboard instantiateInitialViewController];
        NSLog(@"3.5inch");
        self.window.rootViewController = rootViewController;
        }
    
    //4.7inch対応
    CGRect rect2 = [UIScreen mainScreen].bounds;
    if (rect2.size.height == 667) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
        UIViewController* rootViewController = [storyboard instantiateInitialViewController];
        
        self.window.rootViewController = rootViewController;
    }
    
    //5.5inch対応
    CGRect rect3 = [UIScreen mainScreen].bounds;
    if (rect3.size.height == 736) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
        UIViewController* rootViewController = [storyboard instantiateInitialViewController];
        
        self.window.rootViewController = rootViewController;
    }

    //ナビゲーションバーのアイテムの色を変更
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1.000]];
    
    //ナビゲーションバーの色を変更
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.9607843137254902 green:0.16862745098039217 blue:0.00 alpha:1.0];
    
    //ナビゲーションバーのタイトルの色を変更
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // CLLocationManagerのインスタンスを作成
    locationManager = [[CLLocationManager alloc] init];
    // デリゲートを設定
    locationManager.delegate = self;
    // 更新頻度(メートル)
    locationManager.distanceFilter = 100;

    [locationManager startUpdatingLocation];
   
    
    //スプラッシュ時間設定
    sleep(3);
    

    // エラー追跡用の機能を追加する。
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    return YES;

}

-(void)checkGPS{
    // CLLocationManagerのインスタンスを作成
    locationManager = [[CLLocationManager alloc] init];
    // デリゲートを設定
    locationManager.delegate = self;
    // 更新頻度(メートル)
    locationManager.distanceFilter = 100;
    // 取得精度
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // iOS8の対応
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        // 位置情報測位の許可を求めるメッセージを表示する
        [locationManager requestAlwaysAuthorization]; // 常に許可
        
    } else { // iOS7以前
        // 測位開始
        [locationManager startUpdatingLocation];
    }
}




//チューリアルの動作ごとのアクション
#pragma mark - ICETutorialController delegate
- (void)tutorialController:(ICETutorialController *)tutorialController scrollingFromPageIndex:(NSUInteger)fromIndex toPageIndex:(NSUInteger)toIndex {
    NSLog(@"Scrolling from page %lu to page %lu.", (unsigned long)fromIndex, (unsigned long)toIndex);
}

- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController {
    NSLog(@"Tutorial reached the last page.");
}

- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnLeftButton:(UIButton *)sender {
    NSLog(@"Button 1 pressed.");
}

- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnRightButton:(UIButton *)sender {
    NSLog(@"Button 2 pressed.");
    NSLog(@"Auto-scrolling stopped.");
    

     //3.5inchと4inchを読み分けする
     CGRect rect = [UIScreen mainScreen].bounds;
     if (rect.size.height == 480) {
     UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
     UIViewController* rootViewController = [storyboard instantiateInitialViewController];
     NSLog(@"3.5inch");
     self.window.rootViewController = rootViewController;
     }
     
     //4.7inch対応
     CGRect rect2 = [UIScreen mainScreen].bounds;
     if (rect2.size.height == 667) {
     UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
     UIViewController* rootViewController = [storyboard instantiateInitialViewController];
     
     self.window.rootViewController = rootViewController;
     }
     
     //5.5inch対応
     CGRect rect3 = [UIScreen mainScreen].bounds;
     if (rect3.size.height == 736) {
     UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
     UIViewController* rootViewController = [storyboard instantiateInitialViewController];
     
     self.window.rootViewController = rootViewController;
     }
         
    //ナビゲーションバーのアイテムの色を変更
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1.000]];
    
    //ナビゲーションバーの色を変更
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.9607843137254902 green:0.16862745098039217 blue:0.00 alpha:1.0];
    
    //ナビゲーションバーのタイトルの色を変更
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
   
    
    // CLLocationManagerのインスタンスを作成
    locationManager = [[CLLocationManager alloc] init];
    // デリゲートを設定
    locationManager.delegate = self;
    // 更新頻度(メートル)
    locationManager.distanceFilter = 100;
    // 取得精度
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // iOS8の対応
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8以降
        // 位置情報測位の許可を求めるメッセージを表示する
        [locationManager requestAlwaysAuthorization]; // 常に許可
        
    } else { // iOS7以前
        // 測位開始
        [locationManager startUpdatingLocation];
    }
    
    
    
    // エラー追跡用の機能を追加する。
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
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

//位置情報更新処理
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"アップデート呼び出し");
    [self showLocation:location];
}

//緯度経度を変数に格納
- (void)showLocation:(CLLocation *)location
{
    AppDelegate* appDelegateGeo = [[UIApplication sharedApplication] delegate];
    appDelegateGeo.lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    appDelegateGeo.lon =  [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    NSLog(@"latitudeStr:%@",appDelegateGeo.lat);
    NSLog(@"longitudeStr:%@",appDelegateGeo.lon);
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/dist/?lat=%@&lon=%@&limit=30",appDelegateGeo.lat,appDelegateGeo.lon];
        NSLog(@"urlStringatnoulon:%@",urlString);
        NSURL *urlGeo = [NSURL URLWithString:urlString];
        NSString *responseGeo = [NSString stringWithContentsOfURL:urlGeo encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [responseGeo dataUsingEncoding:NSUTF32BigEndianStringEncoding];
        appDelegateGeo.jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    });
        //});
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


- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
        [locationManager stopUpdatingLocation]; //測位停止
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    if (nil == locationManager && [CLLocationManager locationServicesEnabled])
       [locationManager startUpdatingLocation]; //測位再開
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
    [FBSession.activeSession close];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
