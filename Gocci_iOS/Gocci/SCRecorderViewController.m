//
//   VRViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCTouchDetector.h"
#import "SCRecorderViewController.h"
#import "SCAudioTools.h"
#import "SCVideoPlayerViewController.h"
#import "SCRecorderFocusView.h"
#import "SCImageDisplayerViewController.h"
#import "SCRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCRecordSessionManager.h"
#import "RestaurantTableViewController.h"


#define kVideoPreset AVCaptureSessionPresetHigh

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCRecorderViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
}



- (void)showDefaultContentView;

@property (strong, nonatomic) SCRecorderFocusView *focusView;
@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation SCRecorderViewController

#pragma mark - UIViewController 

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

#endif

#pragma mark - Left cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.capturePhotoButton.alpha = 0.0;
    
    _ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _ghostImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ghostImageView.alpha = 0.2;
    _ghostImageView.userInteractionEnabled = NO;
    _ghostImageView.hidden = YES;
    
    [self.view insertSubview:_ghostImageView aboveSubview:self.previewView];

    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = AVCaptureSessionPreset640x480;
    _recorder.audioEnabled = YES;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder.initializeRecordSessionLazily = NO;
    
    self.navigationController.navigationBarHidden = YES;
    [self updateTimeRecordedLabel];
    
    // NavigationBar 非表示
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    //ナビゲーションバーの色を変更
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.9607843137254902 green:0.16862745098039217 blue:0.00 alpha:1.0];
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
    self.loadingView.hidden = YES;
    
    
    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    /*
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    */
     
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSError *error = nil;
        NSLog(@"%@", error);

        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    [_recorder startRunningSession];
    [_recorder focusCenter];
    
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
        [self showDefaultContentView];
    }
}


- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate6"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate6"];
    // 保存
    [userDefaults synchronize];
    // 初回起動
    return YES;
}

- (void)showDefaultContentView
{
    if (!_firstContentView) {
        _firstContentView = [DemoContentView defaultView];
        
        UILabel *descriptionLabel = [[UILabel alloc] init];
        descriptionLabel.frame = CGRectMake(20, 8, 260, 100);
        descriptionLabel.numberOfLines = 0.;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:16.];
        descriptionLabel.text = @"撮影画面では赤い録画ボタンを押して離して合計6秒で飲食店の良さを紹介してください";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareCamera];
    
	self.navigationController.navigationBarHidden = YES;
    [self updateTimeRecordedLabel];
   
    // NavigationBar 非表示
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [_recorder endRunningSession];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {
    [self.focusView hideFocusAnimation];
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)showVideo {
    //エフェクター画面への遷移
    [self performSegueWithIdentifier:@"Video" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCVideoPlayerViewController class]]) {
        SCVideoPlayerViewController *videoPlayer = segue.destinationViewController;
        videoPlayer.recordSession = _recordSession;
    } else if ([segue.destinationViewController isKindOfClass:[SCImageDisplayerViewController class]]) {
        SCImageDisplayerViewController *imageDisplayer = segue.destinationViewController;
        imageDisplayer.photo = _photo;
        _photo = nil;
    }
}

- (void)showPhoto:(UIImage *)photo {
    _photo = photo;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}

- (void) handleReverseCameraTapped:(id)sender {
	[_recorder switchCaptureDevices];
}

- (void) handleStopButtonTapped:(id)sender {
    SCRecordSession *recordSession = _recorder.recordSession;
    
    if (recordSession != nil) {
        [self finishSession:recordSession];
    }
}

- (void)finishSession:(SCRecordSession *)recordSession {
    [recordSession endRecordSegment:^(NSInteger segmentIndex, NSError *error) {
        [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
        
        _recordSession = recordSession;
        [self showVideo];
        [self prepareCamera];
    }];
}

- (void) handleRetakeButtonTapped:(id)sender {
    SCRecordSession *recordSession = _recorder.recordSession;
    
    if (recordSession != nil) {
        _recorder.recordSession = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endRecordSegment:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
	[self prepareCamera];
    [self updateTimeRecordedLabel];
}

- (IBAction)switchCameraMode:(id)sender {
    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.capturePhotoButton.alpha = 0.0;
            self.recordView.alpha = 1.0;
            self.retakeButton.alpha = 1.0;
            self.stopButton.alpha = 1.0;
        } completion:^(BOOL finished) {
			_recorder.sessionPreset = kVideoPreset;
            [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeOff;
        }];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordView.alpha = 0.0;
            self.retakeButton.alpha = 0.0;
            self.stopButton.alpha = 0.0;
            self.capturePhotoButton.alpha = 1.0;
        } completion:^(BOOL finished) {
			_recorder.sessionPreset = AVCaptureSessionPresetPhoto;
            [self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
            [self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeAuto;
        }];
    }
}

- (IBAction)switchFlash:(id)sender {
    NSString *flashModeString = nil;
    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeOn;
                break;
            case SCFlashModeOn:
                flashModeString = @"Flash : Light";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Auto";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
    } else {
        switch (_recorder.flashMode) {
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            default:
                break;
        }
    }
    
    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
}

- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        //最大秒数
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(8, 10000);
        
        _recorder.recordSession = session;
    }
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession {
    [self finishSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginRecordSegment:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didEndRecordSegment:(SCRecordSession *)recordSession segmentIndex:(NSInteger)segmentIndex error:(NSError *)error {
    NSLog(@"End record segment %d at %@: %@", (int)segmentIndex, segmentIndex >= 0 ? [recordSession.recordSegments objectAtIndex:segmentIndex] : nil, error);
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.recordSession != nil) {
        currentTime = _recorder.recordSession.currentRecordDuration;
    }
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.1f 秒", CMTimeGetSeconds(currentTime)];
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
    
}

- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    if (touchDetector.state == UIGestureRecognizerStateBegan) {
        _ghostImageView.hidden = YES;
        [_recorder record];
    } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
        [_recorder pause];
        [self updateGhostImage];
    }
}

- (IBAction)capturePhoto:(id)sender {
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            [self showPhoto:image];
        } else {
            [self showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription];
        }
    }];
}

- (void)updateGhostImage {
    _ghostImageView.image = [_recorder snapshotOfLastAppendedVideoBuffer];
    _ghostImageView.hidden = !_ghostModeButton.selected;
}

- (IBAction)switchGhostMode:(id)sender {
    _ghostModeButton.selected = !_ghostModeButton.selected;
    _ghostImageView.hidden = !_ghostModeButton.selected;
}

@end
