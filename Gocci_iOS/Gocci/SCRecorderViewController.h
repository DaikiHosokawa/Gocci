//
//  VRViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface SCRecorderViewController : UIViewController<SCRecorderDelegate>

@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIView *downBar;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
@property (weak, nonatomic) IBOutlet UIButton *capturePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;

- (IBAction)switchCameraMode:(id)sender;
- (IBAction)switchFlash:(id)sender;
- (IBAction)capturePhoto:(id)sender;
- (IBAction)switchGhostMode:(id)sender;

@end
