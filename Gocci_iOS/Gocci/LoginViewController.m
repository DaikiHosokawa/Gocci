
//  LoginViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TimelineTableViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{

}

-(void) viewWillDisappear:(BOOL)animated{
    AppDelegate* appDelegateGeo = [[UIApplication sharedApplication] delegate];
    //現在地から近い店取得しておく(jsonDicはsearchTableVIewで使う)
    NSString *urlString = [NSString stringWithFormat:@"http://api-gocci.jp/dist/?lat=%@&lon=%@&limit=30",appDelegateGeo.lat,appDelegateGeo.lon];
    NSLog(@"urlStringatnoulon:%@",urlString);
    NSURL *urlGeo = [NSURL URLWithString:urlString];
    NSString *responseGeo = [NSString stringWithContentsOfURL:urlGeo encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [responseGeo dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    appDelegateGeo.jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO]; // ナビゲーションバー非表示

}

//Facebookログインを押す
- (IBAction)facebookButtonTapped:(id)sender {
    // パーミッション
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location",@"publish_stream"];
　　　// Facebook アカウントを使ってログイン
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
         [SVProgressHUD showWithStatus:@"ログイン中" maskType:SVProgressHUDMaskTypeAnimation];
        if (!user) {
            if (!error) {
                NSLog(@"Facebook ログインをユーザーがキャンセル");
                  [SVProgressHUD dismiss];
            } else {
                NSLog(@"Facebook ログイン中にエラーが発生: %@", error);
                [SVProgressHUD dismiss];
            }
        } else if (user.isNew) {
            NSLog(@"Facebook サインアップ & ログイン完了!");
            [self info];
        } else {
            NSLog(@"Facebook ログイン完了!");
            [self info];
        }
    }];
}

//facebookの各種データ取得
-(void)info{
    
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
            logindelegate.username = name;
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            NSString *relationship = userData[@"relationship_status"];
            NSString *pictureURL = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID ];
            AppDelegate* picturedelegate = [[UIApplication sharedApplication] delegate];
            picturedelegate.userpicture = pictureURL;
            
            NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",name,pictureURL];
            NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/login/"];
            NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLResponse* response;
            NSError* error = nil;
            NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                   returningResponse:&response
                                                               error:&error];
            NSLog(@"result:%@",result);
            
            [self performSegueWithIdentifier:@"goTimeline" sender:self];
            NSLog(@"FacebookLogin is completed");

            
            NSLog(@"name=%@",name);
            NSLog(@"location=%@",location);
            NSLog(@"gender=%@",gender);
            NSLog(@"birthday=%@",birthday);
            NSLog(@"relation=%@",relationship);
            NSLog(@"pict=%@",pictureURL);
             [SVProgressHUD dismiss];
        }
    }];
}

//Twitterログインボタンを押す
- (IBAction)twitterButtonTapped:(id)sender {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Twitter ログインをユーザーがキャンセル");
                
                 [SVProgressHUD dismiss];
            } else {
                NSLog(@"Twitter ログイン中にエラーが発生: %@", error);
                
                 [SVProgressHUD dismiss];
            }
        } else if (user.isNew) {
            NSLog(@"Twitter サインアップ & ログイン完了!");
           [SVProgressHUD showWithStatus:@"ログイン中" maskType:SVProgressHUDMaskTypeAnimation];
            [self info2];
           

        } else {
            NSLog(@"Twitter ログイン完了!");
               [SVProgressHUD showWithStatus:@"ログイン中" maskType:SVProgressHUDMaskTypeAnimation];
            [self info2];
           
        }
    }];
}

//Twitterの各種データ取得
-(void)info2{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!error && user) {
            NSString *userId = [PFTwitterUtils twitter].userId;
            NSLog(@"userId:%@",userId);
            NSString *authToken = [PFTwitterUtils twitter].authToken;
           NSLog(@"authToken:%@",authToken);
            NSString *screenName = [PFTwitterUtils twitter].screenName;
            NSLog(@"screenName:%@",screenName);
            AppDelegate* logindelegate = [[UIApplication sharedApplication] delegate];
            logindelegate.username = screenName;
            NSString *pictureURL = [[NSString alloc] initWithFormat:@"http://www.paper-glasses.com/api/twipi/%@", screenName];
            AppDelegate* picturedelegate = [[UIApplication sharedApplication] delegate];
            picturedelegate.userpicture = pictureURL;
            NSLog(@"%@",pictureURL);
            
            NSString *content = [NSString stringWithFormat:@"user_name=%@&picture=%@",screenName,pictureURL];
            NSURL* url = [NSURL URLWithString:@"http://api-gocci.jp/login/"];
            NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLResponse* response;
            NSError* error = nil;
            NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest
                                                   returningResponse:&response
                                                               error:&error];
            NSLog(@"result:%@",result);
            [self performSegueWithIdentifier:@"goTimeline2" sender:self];
            NSLog(@"TwitterLogin is completed");
        [SVProgressHUD dismiss];
        }
    }];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end