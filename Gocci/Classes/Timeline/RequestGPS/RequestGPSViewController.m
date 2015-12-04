//
//  RequestGPSViewController.m
//  Gocci
//
//  Created by Castela on 2015/11/30.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "RequestGPSViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface RequestGPSViewController ()<CLLocationManagerDelegate>

@end

@implementation RequestGPSViewController{
    // ロケーションマネージャー
    CLLocationManager* locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    // Do any additional setup after loading the view.
}


- (IBAction)buttonAction:(id)sender
{
    
    switch ([CLLocationManager authorizationStatus]) {
            
        case kCLAuthorizationStatusNotDetermined:
            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [locationManager requestWhenInUseAuthorization];
            } else {
                [locationManager startUpdatingLocation];
            }
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [locationManager requestWhenInUseAuthorization];
            } else {
                [locationManager startUpdatingLocation];
            }
            break;
            
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            
            NSLog(@"位置情報が許可されていません2");
            UIAlertView *requestAgain  =[[UIAlertView alloc] initWithTitle:@"設定画面より位置情報をONにしてください" message:@"Gocci登録には位置情報が必要です" delegate:self cancelButtonTitle:nil otherButtonTitles:@"設定する", nil];
            requestAgain.tag=121;
            [requestAgain show];
            
            
            break;
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 121 && buttonIndex == 0)
    {
        //code for opening settings app in iOS 8
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
