//
//  VRViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import "CXCardView.h"
#import "DemoContentView.h"

#import "SCFirstView.h"
#import "SCSecondView.h"

@interface SCRecorderViewController : UIViewController<SCRecorderDelegate, UIScrollViewDelegate, SCFirstViewDelegate,SCSecondViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *recordView;
//@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
//@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
//@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
//@property (weak, nonatomic) IBOutlet UIButton *capturePhotoButton;
//@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;
@property (weak, nonatomic) IBOutlet UIView *viewBaseGauge;
@property(nonatomic,strong) UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,strong) UIPageControl *pageControl;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *viewIndicator;

//- (IBAction)switchCameraMode:(id)sender;
//- (IBAction)switchFlash:(id)sender;
//- (IBAction)capturePhoto:(id)sender;
//- (IBAction)switchGhostMode:(id)sender;

#pragma mark - beforeRecorderViewController
-(void)sendTenmeiString:(NSString*)str;
-(void)sendKakakuValue:(int)value;

-(void)execSubmit;
-(void)cancelSubmit;

@end
