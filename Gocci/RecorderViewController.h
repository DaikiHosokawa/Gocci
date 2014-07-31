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

@interface RecorderViewController : UIViewController
{
    ALAssetsLibrary *assetsLibrary_;
    KZCameraView *_cam;
}
@property (nonatomic, strong) KZCameraView *cam;

@end
