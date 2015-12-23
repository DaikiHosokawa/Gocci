//
//   VRViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa.
//  Copyright (c) 2014年 INASE,inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCTouchDetector.h"
#import "SCRecorderViewController.h"
#import "EditVideoController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCRecordSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RestaurantTableViewController.h"
#import "APIClient.h"
#import "SVProgressHUD.h"
#import "SCScrollPageView.h"

#import "EditTableViewController.h"

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "STPopup.h"
#import "const.h"


#define kVideoPreset AVCaptureSessionPresetHigh

// define Segue name
static NSString * const SEGUE_GO_KAKAKUTEXT = @"goKakaku";
static NSString * const SEGUE_GO_BEFORE_RECORDER = @"goBeforeRecorder";
static NSString * const SEGUE_GO_POSTING = @"goPosting";
static NSString * const SEGUE_GO_HITOKOTO = @"goHitokoto";

static SCRecordSession *staticRecordSession;


@interface SCRecorderViewController ()
{
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
    
    NSTimer *timerRecord;
    NSTimeInterval test_timeGauge;
    
    SCScrollPageView *scrollpageview;

}


@property (strong, nonatomic) SCRecorderToolsView *focusView;

@property(nonatomic,strong) SCFirstView *firstView;
@property(nonatomic,strong) SCSecondView *secondView;

@property (weak, nonatomic) IBOutlet UIButton *retakeBtn;

@property (weak, nonatomic) IBOutlet UIButton *reverseBtn;
@property (weak, nonatomic) IBOutlet UIView *preview;

@end


@implementation SCRecorderViewController
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
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _recorder = [SCRecorder recorder];
    _recorder.captureSessionPreset = [SCRecorderTools bestCaptureSessionPresetCompatibleWithAllDevices];
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    _recorder.initializeSessionLazily = NO;
    _recorder.maxRecordDuration = CMTimeMake(RECORD_SECONDS * 600, 600);
    _recorder.videoConfiguration.sizeAsSquare = YES;
    UIView *previewView = self.preview;
    _recorder.previewView = previewView;

    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];

}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
#if (!TARGET_IPHONE_SIMULATOR)
    [_recorder previewViewFrameChanged];
#endif
}

#pragma mark 描画開始前
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self prepareSession];
    
#if 1
    {
        {
            CGRect rect_page = CGRectMake(0, 383, 320, 183);
            // 4inch
            CGRect rect = [UIScreen mainScreen].bounds;
            if (rect.size.height == 480) {
                //3.5inch
                rect_page = CGRectMake(0, 336, 320, 144);
            }
            else if (rect.size.height == 667) {
                //4.7inch
                rect_page = CGRectMake(0, 437, 375, 230);
            }
            else if (rect.size.height == 736) {
                //5.5inch
                rect_page = CGRectMake(0, 478, 414, 260);
            }
            scrollpageview = [[SCScrollPageView alloc] initWithFrame:rect_page];
            {
                firstView = [SCFirstView create];
                firstView.delegate = self;
                secondView = [SCSecondView create];
            }
            [scrollpageview showInView:self.view first:firstView second:secondView];
        }
    }
    
#endif
    
#if (!TARGET_IPHONE_SIMULATOR)
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder stopRunning];
}


- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBufferInSession:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
}



#pragma mark 描画完了後
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#if (!TARGET_IPHONE_SIMULATOR)
    
    [_recorder startRunning];

#else
#endif
}



- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: error = %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: error = %@", videoInputError);
}

#pragma mark 退避開始前


- (void)prepareSession {
    if (_recorder.session == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        
        _recorder.session = session;
    }

    
    [self updateTimeRecordedLabel];
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
    if ([segue.destinationViewController isKindOfClass:[EditVideoController class]]) {
        EditVideoController  *videoPlayer = segue.destinationViewController;
        videoPlayer.delegate = self;
        videoPlayer.recordSession = _recordSession;
    }
}

-(void)recordBegan
{
    [firstView expand];
    [_recorder record];
    NSLog(@"Began record");
}


-(void)recordEnded
{
     [firstView shrink];
    [_recorder pause];
    NSLog(@"Stop record");
}



#pragma mark 撮影完了

//importの時の仕組み
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    SCRecordSessionSegment *segment = [SCRecordSessionSegment segmentWithURL:url info:nil];
    
    [_recorder.session addSegment:segment];
    _recordSession = [SCRecordSession recordSession];
    [_recordSession addSegment:segment];
    
    [self showVideo];
}




- (void)updateTimeRecordedLabel {
    
    //self.tapView.hidden = NO;
    
    CMTime currentTime = kCMTimeZero;
    
    NSTimeInterval time_now = 0.0;
    NSTimeInterval time_max = RECORD_SECONDS;
    
#if (!TARGET_IPHONE_SIMULATOR)
    if (_recorder.session != nil) {
        currentTime = _recorder.session.duration;
        time_now = CMTimeGetSeconds(currentTime);
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
    
    NSLog(@"now:%f,max:%f",time_now,time_max);
    [firstView updatePieChartWith:time_now MAX:time_max];
    
}



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
    
   [self dismissViewControllerAnimated:YES completion:nil];
  
}

#pragma mark - SCFirstView


-(void)DeleteDraft
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)openEdit
{
    EditTableViewController* evc = [EditTableViewController new];
    [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:evc];
    
}

-(void)retake
{
    NSLog(@"retake called");
    
    SCRecordSession *recordSession = _recorder.session;
    
    if (recordSession != nil) {
        _recorder.session = nil;
        
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
    [self prepareSession];
}


#pragma mark - SCPostingViewController
#pragma mark 投稿するボタンを押した時


#pragma mark - 撮り直し
- (IBAction)onRetake:(id)sender {
    [self retake];
}

- (IBAction)onReverse:(id)sender {
    [_recorder switchCaptureDevices];
}

- (IBAction)onDelete:(id)sender {
    
    [self DeleteDraft];
    /*
}else {
        UIAlertView *checkDelete  =[[UIAlertView alloc] initWithTitle:@"終了してよろしいですか？" message:@"撮影中の動画が削除されてしまいます" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        checkDelete.tag=121;
        [checkDelete show];
    }
     */
}

- (void) handleStopButtonTapped:(id)sender {
    [_recorder pause:^{
        [self saveAndShowSession:_recorder.session];
    }];
}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    _recordSession = recordSession;
    [self showVideo];
}

- (void)showVideo {
    [self performSegueWithIdentifier:@"Video" sender:self];
}

- (void)recorder:(SCRecorder *)recorder didCompleteSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteSession:");
    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginSegmentInSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
    
}

- (void)recorder:(SCRecorder *)recorder didCompleteSegment:(SCRecordSessionSegment *)segment inSession:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Completed record segment at %@: %@ (frameRate: %f)", segment.url, error, segment.frameRate);
}
- (void)showPopupWithTransitionStyle:(STPopupTransitionStyle)transitionStyle rootViewController:(UIViewController *)rootViewController
{
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:rootViewController];
    popupController.cornerRadius = 4;
    popupController.transitionStyle = transitionStyle;
    [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:17] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

#pragma mark - 撮影に戻る
- (IBAction)onGoPosting:(id)sender {
#ifdef DEBUG
#endif
}
@end