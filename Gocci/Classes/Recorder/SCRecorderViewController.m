//
//   VRViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SCTouchDetector.h"
#import "SCRecorderViewController.h"
#import "SCAudioTools.h"
#import "SCRecorderFocusView.h"
#import "SCImageDisplayerViewController.h"
#import "SCRecorder.h"
#import "SCRecordSessionManager.h"
#import "RestaurantTableViewController.h"
//#import "GaugeView.h"
#import "RecorderSubmitPopupView.h"
#import "RecorderSubmitPopupAdditionView.h"
#import "APIClient.h"
#import "SCPostingViewController.h"
#import "SVProgressHUD.h"
#import "SCPostingViewController.h"

#import "SCScrollPageView.h"
#import <FBSDKShareKit/FBSDKShareKit.h>


#define kVideoPreset AVCaptureSessionPresetHigh

// !!!:dezamisystem
static NSString * const SEGUE_GO_KAKAKUTEXT = @"goKakaku";
static NSString * const SEGUE_GO_BEFORE_RECORDER = @"goBeforeRecorder";
static NSString * const SEGUE_GO_POSTING = @"goPosting";
static NSString * const SEGUE_GO_HITOKOTO = @"goHitokoto";

static SCRecordSession *staticRecordSession;	// !!!:開放を避けるためにスタティック化
static SCRecorder *_recorder;


@import AVFoundation;
@import AssetsLibrary;


////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCRecorderViewController ()
<RecorderSubmitPopupViewDelegate ,RecorderSubmitPopupAdditionViewDelegate,FBSDKSharingDelegate>
{
//    SCRecorder *_recorder;
	
    UIImage *_photo;
    UIImageView *_ghostImageView;
    DemoContentView *_firstContentView;
    DemoContentView *_secondContentView;
	
	//	GaugeView *gaugeViewTimer;
	NSTimer *timerRecord;
	NSTimeInterval test_timeGauge;
	
	// !!!:dezamisystem・スクロールページ用
	SCScrollPageView *scrollpageview;
	//SCFirstView *dummyfirstvuew;

	
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *viewPageBase;


@property (strong, nonatomic) SCRecorderFocusView *focusView;
@property (nonatomic, strong) RecorderSubmitPopupView *submitView;
@property (nonatomic, strong) RecorderSubmitPopupAdditionView *AdditionView;

// !!!:dezamisystem・スクロールページ用
//@property (nonatomic,strong) UIScrollView *pageingScrollView;
@property(nonatomic,strong) SCFirstView *firstView;
@property(nonatomic,strong) SCSecondView *secondView;
//@property (nonatomic, strong) SCRecordSession *recordSession;	// !!!:開放を避けるためにスタティック化
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewPage;

@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation SCRecorderViewController
//@synthesize pageingScrollView;
@synthesize firstView;
@synthesize secondView;

#pragma mark - UIViewController 

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

#endif

#pragma mark - Left cycle
- (void)viewDidLoad {
	
    [super viewDidLoad];

    
	// ???:ずれを解消出来る？
	self.automaticallyAdjustsScrollViewInsets = NO;

    //self.capturePhotoButton.alpha = 0.0;
	
	// ???:hiddenのまま
	/*
    _ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _ghostImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ghostImageView.alpha = 0.2;
    _ghostImageView.userInteractionEnabled = NO;
    _ghostImageView.hidden = YES;
    [self.view insertSubview:_ghostImageView aboveSubview:self.previewView];
	 */

    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = AVCaptureSessionPreset640x480;
    _recorder.audioEnabled = YES;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder.initializeRecordSessionLazily = NO;
	
//	[self updateTimeRecordedLabel];
	
	UIView *previewView = self.view; // self.previewView;
    _recorder.previewView = previewView;

	// !!!:dezamisystem・削除
	//    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	//	// !!!:未使用なので
	//    //[self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	//	[self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    //[self.recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
	//self.recordView.alpha = 1.0;
	
//	self.loadingView.hidden = YES;
	CGRect rect_focus = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	//NSLog(@"フォーカス矩形：%@", NSStringFromCGRect(rect_focus) );
	self.focusView = [[SCRecorderFocusView alloc] initWithFrame:rect_focus];
	self.focusView.recorder = _recorder;
	[self.view addSubview:self.focusView];
	[self.view sendSubviewToBack:self.focusView];
//    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
//    self.focusView.recorder = _recorder;
//    [previewView addSubview:self.focusView];

    /*
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    */
   
    
#if 1
	// !!!:dezamisystem・スクロールビュー
    
    {
        // !!!:dezamisystem・パラメータ
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [secondView setKakakuValue:delegate.valueKakaku];
        [secondView setTenmeiString:delegate.stringTenmei];
        [secondView setCategoryIndex:delegate.indexCategory];
        [secondView setFunikiIndex:delegate.indexFuniki];
        [secondView setHitokotoValue:delegate.valueHitokoto];
        
        [secondView reloadTableList];
        
        // !!!:ゲージ再描画
        [self updateTimeRecordedLabel];
        
        {
            CGRect rect_page = CGRectMake(0, 398, 320, 170);	// 4inch
            //画面サイズから場合分け
            CGRect rect = [UIScreen mainScreen].bounds;
            if (rect.size.height == 480) {
                //3.5inch
                rect_page = CGRectMake(0, 336, 320, 144);
            }
            else if (rect.size.height == 667) {
                //4.7inch
                rect_page = CGRectMake(0, 467, 375, 200);
            }
            else if (rect.size.height == 736) {
                //5.5inch
                rect_page = CGRectMake(0, 516, 414, 220);
            }
            scrollpageview = [[SCScrollPageView alloc] initWithFrame:rect_page];
            //スクロールビューの上ビュー
            {
                firstView = [SCFirstView create];
                firstView.delegate = self;
                //[pageingScrollView addSubview:firstView];
                secondView = [SCSecondView create];
                secondView.delegate = self;
                //[pageingScrollView addSubview:secondView];
            }
            [scrollpageview showInView:self.view first:firstView second:secondView];
        }
    }

	
#endif
   
	
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

// !!!:未使用
// スクロールビューがスワイプされたとき
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat pageWidth = _scrollView.frame.size.width;
//    if ((NSInteger)fmod(_scrollView.contentOffset.x , pageWidth) == 0) {
//        // ページコントロールに現在のページを設定
//        _pageControl.currentPage = _scrollView.contentOffset.x / pageWidth;
//    }
//}

// !!!:未使用
// ページコントロールがタップされたとき
//- (void)pageControl_Tapped:(id)sender
//{
//    CGRect frame = _scrollView.frame;
//    frame.origin.x = frame.size.width * _pageControl.currentPage;
//    [_scrollView scrollRectToVisible:frame animated:YES];
//}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	
#if (!TARGET_IPHONE_SIMULATOR)
	[_recorder previewViewFrameChanged];
#endif
}

#pragma mark 描画開始前
- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	//NSLog(@"撮影画面矩形：%@", NSStringFromCGRect(self.view.frame) );
	
	//[self prepareCamera];
	
	// NavigationBar 非表示
	[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // !!!:dezamisystem・パラメータ
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [secondView setKakakuValue:delegate.valueKakaku];
    [secondView setTenmeiString:delegate.stringTenmei];
    [secondView setCategoryIndex:delegate.indexCategory];
    [secondView setFunikiIndex:delegate.indexFuniki];
    [secondView setHitokotoValue:delegate.valueHitokoto];
    [secondView reloadTableList];
    
    // !!!:ゲージ再描画
    [self updateTimeRecordedLabel];


}


- (void)showAlert
{
   FirstalertView = [[UIAlertView alloc] initWithTitle:@"価格を入力してください"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    FirstalertView.delegate       = self;
    FirstalertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [FirstalertView show];
}


- (void)showAlert2
{
    SecondalertView = [[UIAlertView alloc] initWithTitle:@"一言を入力してください"
                                                     message:nil
                                                    delegate:self
                                       cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil];
    SecondalertView.delegate       = self;
    SecondalertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [SecondalertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(FirstalertView == alertView){
    if( buttonIndex == alertView.cancelButtonIndex ) { return; }
    
    NSString* textValue = [[alertView textFieldAtIndex:0] text];
    if( [textValue length] > 0 )
    {
        // 入力内容を利用した処理
        NSLog(@"入力内容:%@",textValue);
        [self sendKakakuValue:[textValue intValue]];
        
        // !!!:dezamisystem・パラメータ
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [secondView setKakakuValue:delegate.valueKakaku];
        [secondView reloadTableList];
        }
    }
    if(SecondalertView == alertView){
        
        if( buttonIndex == alertView.cancelButtonIndex ) { return; }
        
        NSString* textValue = [[alertView textFieldAtIndex:0] text];
        if( [textValue length] > 0 )
        {
            // 入力内容を利用した処理
            NSLog(@"入力内容2:%@",textValue);
            [self sendHitokotoValue:textValue];
            
            // !!!:dezamisystem・パラメータ
            AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [secondView setHitokotoValue:delegate.valueHitokoto];
            [secondView reloadTableList];
           
            }
    }
}





#pragma mark 描画完了後
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
#if (!TARGET_IPHONE_SIMULATOR)
    [_recorder startRunningSession];
    [_recorder focusCenter];
#else
//	[self.viewIndicator stopAnimating];	
#endif
	
	static BOOL isPassed = NO;
	if (!isPassed) {
		[self showDefaultContentView];
        
	}
	isPassed = YES;

	// !!!:ゲージ再描画
	[self updateTimeRecordedLabel];
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
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.];
        descriptionLabel.text = @"7秒で飲食店を紹介してください";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: error = %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: error = %@", videoInputError);
}

#pragma mark 退避開始前
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
#if (!TARGET_IPHONE_SIMULATOR)
    [_recorder endRunningSession];
#endif
}

#pragma mark 退避完了後
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {

#if (!TARGET_IPHONE_SIMULATOR)
    [self.focusView showFocusAnimation];
#endif
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {

#if (!TARGET_IPHONE_SIMULATOR)
    [self.focusView hideFocusAnimation];
#endif
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {

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

#pragma mark 遷移前準備
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SCImageDisplayerViewController class]]) {
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

// !!!:未使用
- (void) handleReverseCameraTapped {

[_recorder switchCaptureDevices];

}

// !!!:未使用
//- (void) handleStopButtonTapped:(id)sender {
//	
//#if (!TARGET_IPHONE_SIMULATOR)
//    SCRecordSession *recordSession = _recorder.recordSession;
//    
//    if (recordSession != nil) {
//        [self finishSession:recordSession];
//    }
//#endif
//}

#pragma mark 撮影完了
- (void)finishSession:(SCRecordSession *)recordSession {
	
#if (!TARGET_IPHONE_SIMULATOR)

    [recordSession endRecordSegment:^(NSInteger segmentIndex, NSError *error) {
        [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
        
		//   self.recordSession = recordSession;
		staticRecordSession = recordSession;
        [self _complete];
        [self prepareCamera];
    }];
#endif
}

#pragma mark Retakeイベント
// !!!:未使用
// retakeButtonでタップを判定し、押されたときに撮影秒数をゼロにするボタンです
//- (void) handleRetakeButtonTapped:(id)sender
//{
//#if (!TARGET_IPHONE_SIMULATOR)
//    SCRecordSession *recordSession = _recorder.recordSession;
//    
//    if (recordSession != nil) {
//        _recorder.recordSession = nil;
//        
//        // If the recordSession was saved, we don't want to completely destroy it
//        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
//            [recordSession endRecordSegment:nil];
//        } else {
//            [recordSession cancelSession:nil];
//        }
//    }
//    
//	[self prepareCamera];
//    [self updateTimeRecordedLabel];
//#else
//	[self prepareCamera];
//	[self updateTimeRecordedLabel];
//#endif
//}

// !!!:未使用
//#pragma mark カメラモード切り替えイベント
//- (IBAction)switchCameraMode:(id)sender
//{
//#if (!TARGET_IPHONE_SIMULATOR)
//    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//           // self.capturePhotoButton.alpha = 0.0;
//            self.recordView.alpha = 1.0;
//            self.retakeButton.alpha = 1.0;
//           // self.stopButton.alpha = 1.0;
//        } completion:^(BOOL finished) {
//			_recorder.sessionPreset = kVideoPreset;
//           // [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
//           // [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
//            _recorder.flashMode = SCFlashModeOff;
//        }];
//    } else {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.recordView.alpha = 0.0;
//            self.retakeButton.alpha = 0.0;
//            //self.stopButton.alpha = 0.0;
//            //self.capturePhotoButton.alpha = 1.0;
//        } completion:^(BOOL finished) {
//			_recorder.sessionPreset = AVCaptureSessionPresetPhoto;
//            //[self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
//            //[self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
//            _recorder.flashMode = SCFlashModeAuto;
//        }];
//    }
//#else
//	NSLog(@"%s",__func__);
//#endif
//}

- (IBAction)switchFlash:(id)sender
{
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
- (void) prepareCamera
{
#if (!TARGET_IPHONE_SIMULATOR)
	//if (_recorder.recordSession == nil)
	{
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
    NSLog(@"Began record segment: error = %@", error);
}

//セグメントを保存している(トリミングするならここ)
- (void)recorder:(SCRecorder *)recorder didEndRecordSegment:(SCRecordSession *)recordSession segmentIndex:(NSInteger)segmentIndex error:(NSError *)error {
    NSLog(@"End record segment %d at %@: error = %@", (int)segmentIndex, segmentIndex >= 0 ? [recordSession.recordSegments objectAtIndex:segmentIndex] : nil, error);
}

- (void)updateTimeRecordedLabel {
    
    //self.tapView.hidden = NO;
	
    CMTime currentTime = kCMTimeZero;
	
	NSTimeInterval time_now = 0.0;
	NSTimeInterval time_max = 8.0;
#if (!TARGET_IPHONE_SIMULATOR)
    if (_recorder.recordSession != nil) {
        currentTime = _recorder.recordSession.currentRecordDuration;
		
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
	//    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.1f 秒", time_now];
	
	// !!!:・円グラフゲージ
	[firstView updatePieChartWith:time_now MAX:time_max];

}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {

	[self updateTimeRecordedLabel];
}

#pragma mark 撮影イベント開始
// !!!:dezamisystem・SCFirstView側でDelegate化して、[self recordBegan]と[self recordEnded]に移行
// recordViewでタップの有無を判定し、押している時だけ撮影、話している時にストップで作っています。
//- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
//	
//
//    if (touchDetector.state == UIGestureRecognizerStateBegan) {
//#if (!TARGET_IPHONE_SIMULATOR)
//        _ghostImageView.hidden = YES;
//        [_recorder record];
//#else
//		if (timerRecord) {
//			[timerRecord invalidate];
//			timerRecord = nil;
//		}
//		test_timeGauge = 0.0;
//		const NSTimeInterval interval = 1.0 / 60.0;
//		timerRecord = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateTimeRecordedLabel) userInfo:nil repeats:YES];
//#endif
//    }
//	else if (touchDetector.state == UIGestureRecognizerStateEnded) {
//#if (!TARGET_IPHONE_SIMULATOR)
//        [_recorder pause];
//        [self updateGhostImage];
//#else
//		if (timerRecord) {
//			[timerRecord invalidate];
//			timerRecord = nil;
//		}
//		test_timeGauge = 0.0;
//
//        [self _complete];
//#endif
//    }
//}

- (IBAction)capturePhoto:(id)sender {
	
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
	
#if (!TARGET_IPHONE_SIMULATOR)
    _ghostImageView.image = [_recorder snapshotOfLastAppendedVideoBuffer];
    //_ghostImageView.hidden = !_ghostModeButton.selected;
#endif
}

- (IBAction)switchGhostMode:(id)sender {
	
#if (!TARGET_IPHONE_SIMULATOR)
   // _ghostModeButton.selected = !_ghostModeButton.selected;
   // _ghostImageView.hidden = !_ghostModeButton.selected;
#endif
}


#pragma mark - RecorderSubmitPopupViewDelegate
#pragma mark Twitter へ投稿
- (void)recorderSubmitPopupViewOnTwitterShare
{
    LOG_METHOD;
    
    //注意：Twitterのメソッドをここに書く
    
    // Twitter へ投稿
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    // TODO: この URL は有効？
    //       動画を API に投稿してからじゃないとアクセスできない？
    AppDelegate *appDelegete2 = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *urlString = [NSString stringWithFormat:@"%@movies/%@", API_BASE_URL, appDelegete2.postFileName];
    
    [controller setInitialText:@"グルメ動画アプリ「Gocci」からの投稿"];
    [controller addURL:[NSURL URLWithString:urlString]];
    controller.completionHandler = ^(SLComposeViewControllerResult res) {
        LOG(@"res=%@", @(res));
        
        if (res == SLComposeViewControllerResultDone) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    [self presentViewController:controller animated:YES completion:nil];
    
}
#pragma mark Facebook へ投稿
- (void)recorderSubmitPopupViewOnFacebookShare
{
    LOG_METHOD;
    
    //注意：FacebookShareのメソッドをここに書く
    
    /*
    [SVProgressHUD show];
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
  
    delegate.session = [[FBSession alloc] init];
   
    [FBSession setActiveSession:delegate.session];
    
    [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        // ログイン後の処理
    }];
    
    
    
    
    // Facebook へ投稿
    // プライバシー (公開範囲) の設定
    NSError *error = nil;
    //要注意　共有範囲はSELFのまま
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{
                                                             @"value":@"CUSTOM",
                                                             @"friends":@"SELF"
                                                             }
                                                   options:2
                                                     error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSData *movieData = [[NSData alloc] initWithContentsOfURL:self.recordSession.outputUrl];
	NSData *movieData = [[NSData alloc] initWithContentsOfURL:staticRecordSession.outputUrl];
	
    // パラメータの設定
    NSMutableDictionary *params = @{
                                    @"message": @"Gocciからの投稿",
                                    @"privacy": jsonString,
                                    @"movie.mp4": movieData,
                                    @"title": delegate.gText,
                                    }.mutableCopy;
    
    // リクエストの生成
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/videos"
                                              parameters:params
                                              HTTPMethod:@"POST"];
    
    //コネクションをセットしてすぐキャンセル→NSMutableURLRequestを生成するため???
    //ここはStack Overflowの受け売り
    FBRequestConnection *requestConnection = [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    }];
    [requestConnection cancel];
    
    // 送信
    NSMutableURLRequest *urlRequest = requestConnection.urlRequest;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        LOG(@"success / responseObject=%@", responseObject);
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        LOG(@"failure / error=%@", error);
        [SVProgressHUD dismiss];
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
     */
    /*
    FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
    video.videoURL = staticRecordSession.outputUrl;
    FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
    content.video = video;
    [FBSDKShareDialog showFromViewController:self
                               withContent:content
                                    delegate:nil];
     */
    /*
    FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = staticRecordSession.outputUrl;
    content.contentDescription = @"test";
    content.contentTitle = @"New Post";
    BOOL ok = [[FBSDKShareAPI shareWithContent:content delegate:self] share];
    */
     
   
}



#pragma mark 投稿
// !!!:未使用
//- (void)recorderSubmitPopupViewOnSubmit:(RecorderSubmitPopupView *)view
//{
//    //セッションが7秒未満の時
//     CMTime currentRecordDuration = _recordSession.currentRecordDuration;
//    
//   if (currentRecordDuration.timescale < 7) {
//        NSString *alertMessage = @"まだ7秒撮れていません";
//        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alrt show];
//    }
//    
//    else  {
//        //NSLog(@"ここが通っている") ;
//        
//    [SVProgressHUD show];
//    
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    
//    // サーバへデータを送信
//    __weak typeof(self)weakSelf = self;
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    //バックグラウンドで投稿
//    
//        // movie
//        [APIClient movieWithFilePathURL:weakSelf.recordSession.outputUrl restname:appDelegate.gText star_evaluation:appDelegate.cheertag handler:^(id result, NSUInteger code, NSError *error)
//         {
//             LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
//             
//             if (error){
//               
//             }
//
//             }];
//  
//              NSLog(@"restname:%@,star_evaluation:%@",appDelegate.gText,appDelegate.cheertag);
//              
//              [SVProgressHUD dismiss];
//              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//              
//              // 画面を閉じる
//              [weakSelf dismissViewControllerAnimated:YES completion:nil];
//        
//    }
//}

- (IBAction)popButton:(UIButton *)sender {
    //// 投稿画面を表示
    __weak typeof(self)weakSelf = self;
    
    // 投稿画面を設定
    self.AdditionView = [RecorderSubmitPopupAdditionView view];
    self.AdditionView.delegate = self;
    self.AdditionView.cancelCallback = ^{
        // 投稿画面を閉じる
        [weakSelf.AdditionView dismiss];
        
        // 動画撮影画面を閉じる
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    // 投稿画面を表示
    [weakSelf.AdditionView showInView:weakSelf.view];
}


#pragma mark - Private Methods

#pragma mark Complete完了処理
/**
 *  完了処理
 */
- (void)_complete
{
	[SVProgressHUD show];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //__weak typeof(self)weakSelf = self;
	
#if 0
    // 投稿画面を設定
    self.submitView = [RecorderSubmitPopupView view];
    self.submitView.delegate = self;
    self.submitView.cancelCallback = ^{
        // 投稿画面を閉じる
        [weakSelf.submitView dismiss];
        
        // 動画撮影画面を閉じる
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    // 動画を書き出し・保存
    [self.recordSession mergeRecordSegments:^(NSError *error) {
        [SVProgressHUD dismiss];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error) {
            [weakSelf _showUploadErrorAlertWithMessage:error.localizedDescription];
            return;
        }
        
        // 動画をカメラロールに保存
        [weakSelf.recordSession saveToCameraRoll];
        
         // カメラを停止
         [_recorder endRunningSession];
        
        // 投稿画面を表示
        [weakSelf.submitView showInView:weakSelf.view];
    }];
#else
	// 動画を書き出し・保存
	//[self.recordSession mergeRecordSegments:^(NSError *error)
	[staticRecordSession mergeRecordSegments:^(NSError *error)
	 {
		[SVProgressHUD dismiss];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		if (error) {
			[self _showUploadErrorAlertWithMessage:error.localizedDescription];
			return;
		}
		
		// 動画をカメラロールに保存
		//[self.recordSession saveToCameraRoll];
		[staticRecordSession saveToCameraRoll];
		
		// カメラを停止
		[_recorder endRunningSession];
		
		// 投稿画面を表示
		[self performSegueWithIdentifier:SEGUE_GO_POSTING sender:self];
	}];
#endif
}

/**
 *  保存・投稿失敗アラート
 *
 *  @param message
 */
- (void)_showUploadErrorAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存失敗しました！撮り直してください"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - バックボタン
- (IBAction)onBackbutton:(id)sender {
	
	// !!!:dezamisystem・タブ間を移動、タイムラインへ
	//self.tabBarController.selectedIndex = 0;
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:^{
//        //
//    }];
}

//#pragma mark - UIScrollViewDelegate
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//	// UIScrollViewのページ切替時イベント:UIPageControlの現在ページを切り替える処理
////	pager.currentPage = self.scrollviewPage.contentOffset.x / self.view.frame.size.width;
//}

//#pragma mark - UIPageControle
//- (void)changePageControl:(id)sender {
//}

#pragma mark - SCFirstView
-(void)recordBegan
{
	_ghostImageView.hidden = YES;
	[_recorder record];
}
-(void)recordEnded
{
	[_recorder pause];
	[self updateGhostImage];
}
-(void)flipCamera
{
	[_recorder switchCaptureDevices];
}
-(void)retake
{
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

#pragma mark - SCSecondView
-(void)goBeforeRecorder
{
	//遷移：beforeRecorderTableViewController
	[self performSegueWithIdentifier:SEGUE_GO_BEFORE_RECORDER sender:self];
}
-(void)goKakakuText
{
    
    [self showAlert];
	//遷移：SCRecorderVideoController
	//[self performSegueWithIdentifier:SEGUE_GO_KAKAKUTEXT sender:self];
}

-(void)goHitokotoText
{
    [self showAlert2];
    //遷移：SCRecorderVideoController
   //[self performSegueWithIdentifier:SEGUE_GO_HITOKOTO sender:self];
}

#pragma mark - beforeRecorderViewController
-(void)sendTenmeiString:(NSString*)str
{
	if (!str) return;
	
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

	delegate.stringTenmei = [NSString stringWithString:str];
}

#pragma mark - KakakuTextViewController
-(void)sendKakakuValue:(int)value
{
	AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
	delegate.valueKakaku = value;
}

-(void)sendHitokotoValue:(NSString *)value
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.valueHitokoto = value;
}


#pragma mark - SCPostingViewController
#pragma mark 投稿
-(void)execSubmit
{
    
//	//セッションが7秒未満の時
//	CMTime currentRecordDuration = staticRecordSession.currentRecordDuration;
//	if (currentRecordDuration.timescale < 7) {
//		NSString *alertMessage = @"まだ7秒撮れていません";
//		UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//		[alrt show];
//	}
//	else
	{
		NSLog(@"%s",__func__) ;
		
		[SVProgressHUD show];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		// サーバへデータを送信
		//__weak typeof(self)weakSelf = self;
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		
		NSLog(@"%@",staticRecordSession.outputUrl);
		NSLog(@"restname:%@,star_evaluation:%d",appDelegate.gText,appDelegate.cheertag);
		
		NSString *gText = @"none";
		if (appDelegate.gText) gText = appDelegate.gText;
		int cheertag = 1;
		if (appDelegate.cheertag) cheertag = appDelegate.cheertag;
        int valueKakaku = 0;
        if (appDelegate.valueKakaku) valueKakaku = appDelegate.valueKakaku;
        NSString *atmosphere = @"none";
        if (appDelegate.stringFuniki) atmosphere = appDelegate.stringFuniki;
        NSString *category = @"none";
        NSLog(@"雰囲気は:%@",appDelegate.stringFuniki);
        if (appDelegate.stringCategory) category= appDelegate.stringCategory;
        NSString *comment = @"...";
        NSLog(@"カテゴリーは:%@",appDelegate.stringCategory);
        if (appDelegate.valueHitokoto) comment = appDelegate.valueHitokoto;

		//バックグラウンドで投稿
		// movie
        
		[APIClient movieWithFilePathURL:staticRecordSession.outputUrl
							   restname:gText
		 				star_evaluation:1
                        value:valueKakaku
                        category:category
                        atmosphere:atmosphere
                        comment:comment
								handler:^(id result, NSUInteger code, NSError *error)
		 {
			 LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
             
			 if (error){
				 
			 }
		 }];
		
        appDelegate.stringTenmei = @"";
        appDelegate.gText = nil;
        appDelegate.valueHitokoto = @"";
        appDelegate.valueKakaku = 0;
        appDelegate.indexCategory = -1;
        appDelegate.indexFuniki = -1;
        
        [secondView setKakakuValue:appDelegate.valueKakaku];
        [secondView setTenmeiString:appDelegate.stringTenmei];
        [secondView setCategoryIndex:appDelegate.indexCategory];
        [secondView setFunikiIndex:appDelegate.indexFuniki];
        [secondView setHitokotoValue:appDelegate.valueHitokoto];
        [secondView reloadTableList];

		[SVProgressHUD dismiss];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

-(void)cancelSubmit
{
	NSLog(@"%s",__func__);
	
//	[self retake];
	
	//SCRecordSession *recordSession = _recorder.recordSession;
	//
	//    if (recordSession != nil) {
	//        _recorder.recordSession = nil;
	//
	//        // If the recordSession was saved, we don't want to completely destroy it
	//        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
	//            [recordSession endRecordSegment:nil];
	//        } else {
	//            [recordSession cancelSession:nil];
	//        }
	//    }
	//
	//	[self prepareCamera];
	//    [self updateTimeRecordedLabel];

}


#pragma mark - 戻る
- (IBAction)popViewController1:(UIStoryboardSegue *)segue {

    
	NSLog(@"%s",__func__);
	
	[self retake];
}
- (IBAction)onRetake:(id)sender {
    
    [self retake];
}


#pragma mark - DEBUG
- (IBAction)onGoPosting:(id)sender {
#ifdef DEBUG
//	[self performSegueWithIdentifier:SEGUE_GO_POSTING sender:self];
#endif
}

@end
