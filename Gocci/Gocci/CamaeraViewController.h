//
//  CamaeraViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/11.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "ViewController.h"

@interface CamaeraViewController : ViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@property (weak, nonatomic) IBOutlet UIImageView *previewWindow;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UIButton *pause;
@property (weak, nonatomic) IBOutlet UIButton *stop;

- (IBAction)startCapture;
- (IBAction)pauseCapture;
- (IBAction)endCapture;


@end
