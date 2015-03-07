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
#import <GoogleMaps/GoogleMaps.h>


@interface AppDelegate() {
	UITabBarController *tabBarController;
}

@end


@implementation AppDelegate
// !!!:dezamisystem
@synthesize movieData;
@synthesize jsonDic;
@synthesize gText;
@synthesize username;
@synthesize userpicture;
@synthesize postFileName;


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
{    [Crittercism enableWithAppID: @"540ab4d40729df53fc000003"];
    
    [Parse setApplicationId:@"qsmkpvh1AYaZrn1TFstVfe3Mo1llQ9Nfu6NbHcER" clientKey:@"mkjXAp9MVKUvQmRgIm7vZuPYsAtCB2cz9vCJzJve"];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    [GMSServices provideAPIKey:@"AIzaSyDfZOlLwFm0Wv13lNgJF9nsfXlAmUTzHko"];
    
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
		NSLog(@"4.7inch");

		self.window.rootViewController = rootViewController;
    }
    
    //5.5inch対応
    CGRect rect3 = [UIScreen mainScreen].bounds;
    if (rect3.size.height == 736) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
        UIViewController* rootViewController = [storyboard instantiateInitialViewController];
		NSLog(@"5.5inch");
		
		self.window.rootViewController = rootViewController;
    }

	// !!!:dezamisystem
	UIColor *color_custom = [UIColor colorWithRed:230./255. green:51./255. blue:51./255. alpha:1.];

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
		[UITabBar appearance].barTintColor = [UIColor whiteColor];
		
		// 選択時
		[[UITabBar appearance] setTintColor:color_custom];
	}
	
    //スプラッシュ時間設定
    sleep(3);
	

    // エラー追跡用の機能を追加する。
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    return YES;

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

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
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
