//
//  RecorderViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/06/23.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "KZCameraView.h"
#import "submitViewController.h"

@interface RecorderViewController : UIViewController
{
    ALAssetsLibrary *assetsLibrary_;
    KZCameraView *_cam;
    UIAlertView *firstAlert;

}
@property (nonatomic, strong) KZCameraView *cam;

typedef void (^IsMicAccessEnableWithIsShowAlertBlock)(BOOL isMicAccessEnable);

+ (void)isMicAccessEnableWithIsShowAlert:(BOOL)_isShowAlert
                              completion:(IsMicAccessEnableWithIsShowAlertBlock)_completion;

@end
