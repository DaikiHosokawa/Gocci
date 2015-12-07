//
//  requestGPSPopupViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/21.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "requestGPSPopupViewController.h"
#import "STPopup.h"
#import "SingleLineTextField.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface requestGPSPopupViewController()<CLLocationManagerDelegate>

@end

@implementation requestGPSPopupViewController
{
    UILabel *_label;
    UIView *_separatorView;
    UITextField *_textField;
    UIImageView *_imageView;

    // ロケーションマネージャー
    CLLocationManager* locationManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"現在地の許可";
        self.contentSizeInPopup = CGSizeMake(300, 100);
        self.landscapeContentSizeInPopup = CGSizeMake(300, 200);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 150.0f, 50.0f);
    [button setTitle:@"GPSを許可する" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    // ボタンが押された時にhogeメソッドを呼び出す
    button.center = self.view.center;
    [button addTarget:self
               action:@selector(hoge:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    
}


-(void)hoge:(UIButton*)button{
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
            
            //GPS request was denied
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
 self.textField.placeholder = @"値段を入力";
 self.textField.keyboardType = UIKeyboardTypeNumberPad;
 self.textField.delegate = self;
 [self.view addSubview:self.textField];
 UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
 //numberToolbar.barStyle = UIBarStyleBlackTranslucent;
 numberToolbar.tintColor = [UIColor whiteColor];
 UIBarButtonItem *button1 = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)];
 button1.tintColor = [UIColor blackColor];
 UIBarButtonItem *button2 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
 UIBarButtonItem *button3 = [[UIBarButtonItem alloc]initWithTitle:@"OK" style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad)];
 button3.tintColor = [UIColor blackColor];
 button2.tintColor = [UIColor blackColor];
 numberToolbar.items = @[button1,button2, button3];
 [numberToolbar sizeToFit];
 self.textField.inputAccessoryView = numberToolbar;
 // Do any additional setup after loading the view.
 */

@end
