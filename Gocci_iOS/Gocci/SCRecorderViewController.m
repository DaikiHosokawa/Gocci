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

#import "GaugeView.h" // !!!:dezamisystem

#define kVideoPreset AVCaptureSessionPresetHigh

// !!!:dezamisystem
static NSString * const SEGUE_GO_SC_VIDEO = @"goSCVideo";


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
	
	GaugeView *gaugeViewTimer;	// !!!:dezamisystem
	NSTimer *timerRecord;
	NSTimeInterval test_timeGauge;
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
	
	// !!!:dezamisystem
	//const CGFloat height_status = [[UIApplication sharedApplication] statusBarFrame].size.height;
	CGRect rect_gauge = CGRectMake(0, 0, self.viewBaseGauge.frame.size.width, self.viewBaseGauge.frame.size.height);
	gaugeViewTimer = [[GaugeView alloc] initWithFrame:rect_gauge];
	[self.viewBaseGauge addSubview:gaugeViewTimer];
	[self.viewBaseGauge sendSubviewToBack:gaugeViewTimer];
	self.viewBaseGauge.backgroundColor = [UIColor clearColor];
	[gaugeViewTimer updateWithPer:0.5];
	
	// !!!:dezamisystem
    //self.capturePhotoButton.alpha = 0.0;
	
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

	// !!!:dezamisystem
//	self.navigationController.navigationBarHidden = YES;
	
	[self updateTimeRecordedLabel];
    // NavigationBar 非表示
	// !!!:dezamisystem
//	[self.navigationController setNavigationBarHidden:NO animated:YES];

    //ナビゲーションバーの色を変更
	// !!!:dezamisystem
//	[UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.9607843137254902 green:0.16862745098039217 blue:0.00 alpha:1.0];
	
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;

    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	// !!!:dezamisystem・未使用なので
    //[self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
	
    [self.recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
	self.recordView.alpha = 1.0;
	self.loadingView.hidden = YES;
    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    /*
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    */
     
#if (!TARGET_IPHONE_SIMULATOR)
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
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [_recorder startRunningSession];
    [_recorder focusCenter];
#else
	[self.viewIndicator stopAnimating];	
#endif
	
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
	
	// !!!:dezamisystem
//	self.navigationController.navigationBarHidden = YES;
	
	[self updateTimeRecordedLabel];
	
    // NavigationBar 非表示
	[self.navigationController setNavigationBarHidden:YES animated:NO];	
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [_recorder previewViewFrameChanged];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [_recorder endRunningSession];
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

	// !!!:dezamisystem
//	self.navigationController.navigationBarHidden = NO;
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [self.focusView showFocusAnimation];
#endif
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [self.focusView hideFocusAnimation];
#endif
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [self.focusView showFocusAnimation];
#endif
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - Segue
#pragma mark エフェクター画面への移行
- (void)showVideo {
    //エフェクター画面への遷移
//    [self performSegueWithIdentifier:@"Video" sender:self];
	// !!!:dezamisystem
	[self performSegueWithIdentifier:SEGUE_GO_SC_VIDEO sender:self];
}

#pragma mark 遷移前準備
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SCVideoPlayerViewController class]]) {
        SCVideoPlayerViewController *videoPlayer = segue.destinationViewController;
        videoPlayer.recordSession = _recordSession;
    } else if ([segue.destinationViewController isKindOfClass:[SCImageDisplayerViewController class]]) {
        SCImageDisplayerViewController *imageDisplayer = segue.destinationViewController;
        imageDisplayer.photo = _photo;
        _photo = nil;
    }
}

#pragma mark フォト画面へ遷移
- (void)showPhoto:(UIImage *)photo {
    _photo = photo;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}

- (void) handleReverseCameraTapped:(id)sender {
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
	[_recorder switchCaptureDevices];
#else
	NSLog(@"%s",__func__);
#endif
}

- (void) handleStopButtonTapped:(id)sender {
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    SCRecordSession *recordSession = _recorder.recordSession;
    
    if (recordSession != nil) {
        [self finishSession:recordSession];
    }
#endif
}

- (void)finishSession:(SCRecordSession *)recordSession {
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)

    [recordSession endRecordSegment:^(NSInteger segmentIndex, NSError *error) {
        [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
        
        _recordSession = recordSession;
        [self showVideo];
        [self prepareCamera];
    }];
#endif
}

#pragma mark Retakeイベント
// retakeButtonでタップを判定し、押されたときに撮影秒数をゼロにするボタンです
- (void) handleRetakeButtonTapped:(id)sender
{
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
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
#else
	[self prepareCamera];
	[self updateTimeRecordedLabel];
#endif
}

#pragma mark カメラモード切り替えイベント
- (IBAction)switchCameraMode:(id)sender
{
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
           // self.capturePhotoButton.alpha = 0.0;
            self.recordView.alpha = 1.0;
            self.retakeButton.alpha = 1.0;
           // self.stopButton.alpha = 1.0;
        } completion:^(BOOL finished) {
			_recorder.sessionPreset = kVideoPreset;
           // [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
           // [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeOff;
        }];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.recordView.alpha = 0.0;
            self.retakeButton.alpha = 0.0;
            //self.stopButton.alpha = 0.0;
            //self.capturePhotoButton.alpha = 1.0;
        } completion:^(BOOL finished) {
			_recorder.sessionPreset = AVCaptureSessionPresetPhoto;
            //[self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
            //[self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
            _recorder.flashMode = SCFlashModeAuto;
        }];
    }
#else
	NSLog(@"%s",__func__);
#endif
}

- (IBAction)switchFlash:(id)sender
{
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
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
    
    //[self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
#else
	NSLog(@"%s",__func__);
#endif
}

#pragma mark - カメラ準備
- (void) prepareCamera {
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        //最大秒数
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(7, 10000);
        
        _recorder.recordSession = session;
    }
#else
#endif
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
	
	NSTimeInterval time_now = 0.0;
	NSTimeInterval time_max = 8.0;
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    if (_recorder.recordSession != nil) {
        currentTime = _recorder.recordSession.currentRecordDuration;
		
		// !!!:dezamisystem
		time_now = CMTimeGetSeconds(currentTime);
		
		CMTime cmMaxTime = _recorder.recordSession.suggestedMaxRecordDuration;
		time_max = CMTimeGetSeconds(cmMaxTime);
    }
#else
	const NSTimeInterval interval = 1.0 / 60.0;
	if (timerRecord) {
		test_timeGauge += interval;
	}
	else {
		test_timeGauge = 0.0;
	}
	time_now = test_timeGauge;
#endif
	
	//currentTimelをラベルに表示する
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.1f 秒", time_now];
	
	//ゲージ
	double time_per = time_now / time_max;
	[gaugeViewTimer updateWithPer:time_per];
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {

	[self updateTimeRecordedLabel];
}

#pragma mark 撮影イベント開始
// recordViewでタップの有無を判定し、押している時だけ撮影、話している時にストップで作っています。
- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
	
	// !!!:dezamisystem

    if (touchDetector.state == UIGestureRecognizerStateBegan) {
#if (!TARGET_IPHONE_SIMULATOR)
        _ghostImageView.hidden = YES;
        [_recorder record];
#else
		if (timerRecord) {
			[timerRecord invalidate];
			timerRecord = nil;
		}
		test_timeGauge = 0.0;
		const NSTimeInterval interval = 1.0 / 60.0;
		timerRecord = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateTimeRecordedLabel) userInfo:nil repeats:YES];
#endif
    }
	else if (touchDetector.state == UIGestureRecognizerStateEnded) {
#if (!TARGET_IPHONE_SIMULATOR)
        [_recorder pause];
        [self updateGhostImage];
#else
		if (timerRecord) {
			[timerRecord invalidate];
			timerRecord = nil;
		}
		test_timeGauge = 0.0;

		[self showVideo];
#endif
    }
}

- (IBAction)capturePhoto:(id)sender {
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            [self showPhoto:image];
        } else {
            [self showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription];
        }
    }];
#endif
}

- (void)updateGhostImage {
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    _ghostImageView.image = [_recorder snapshotOfLastAppendedVideoBuffer];
    //_ghostImageView.hidden = !_ghostModeButton.selected;
#endif
}

- (IBAction)switchGhostMode:(id)sender {
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
   // _ghostModeButton.selected = !_ghostModeButton.selected;
   // _ghostImageView.hidden = !_ghostModeButton.selected;
#endif
}


@end
