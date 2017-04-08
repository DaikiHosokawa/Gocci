//
//  requestGPSPopupViewController.m
//  Gocci
//
//  Created by Castela on 2015/10/21.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "requestPushPopupViewController.h"
#import "STPopup.h"
#import "SingleLineTextField.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface requestPushPopupViewController()<CLLocationManagerDelegate>

@end

@implementation requestPushPopupViewController
{
    UILabel *_label;
    UIView *_separatorView;
    UITextField *_textField;
    UIImageView *_imageView;

}

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"通知の許可";
        self.contentSizeInPopup = CGSizeMake(250, 180);
        self.landscapeContentSizeInPopup = CGSizeMake(250, 280);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backImage = [[UIImageView alloc] init];
    backImage.frame = CGRectMake(75, 20, 100, 100);
    backImage.image = [UIImage imageNamed:@"requestPush.png"];
    [self.view addSubview:backImage];
    backImage.userInteractionEnabled = YES;
    backImage.tag = 1;
    
    UILabel *requestLabel = [[UILabel alloc] init];
    requestLabel.text = @"動画への反応が通知で届きます";
    requestLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    requestLabel.frame = CGRectMake(28, 130, 220, 20);
    [self.view addSubview:requestLabel];
    
    UILabel *description = [[UILabel alloc] init];
    description.text = @"※画像をタップしてください";
    description.font = [UIFont fontWithName:@"Helvetica" size:11];
    description.frame = CGRectMake(55, 150, 220, 20);
    [self.view addSubview:description];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self checkPermissionOfNotification];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 121 && buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


- (void)checkPermissionOfNotification {
    
    UIUserNotificationSettings *currentSettings = [[UIApplication
                                                    sharedApplication] currentUserNotificationSettings];
   
    if (currentSettings.types == UIUserNotificationTypeNone) {
        
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"通知設定がオフになっています" message:@"呼び出しを有効にするには設定画面より通知を許可して下さい。"
                                  delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        alert.tag = 121;
        [alert show];
    
    }
}
@end
