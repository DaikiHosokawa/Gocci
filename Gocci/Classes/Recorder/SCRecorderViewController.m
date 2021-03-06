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

#import "informationController.h"

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "STPopup.h"
#import "const.h"
#import "Swift.h"


#define kVideoPreset AVCaptureSessionPresetHigh


static SCRecordSession *staticRecordSession;


@interface SCRecorderViewController ()
{
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
    
    NSTimer *timerRecord;
    NSTimeInterval test_timeGauge;
    
    SCScrollPageView *scrollpageview;
    
    bool deleteUserInsertedData;

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
    
#if !TARGET_IPHONE_SIMULATOR && !defined SKIP_VIDEO_RECORDING
    
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
#endif
    
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
#if !TARGET_IPHONE_SIMULATOR && !defined SKIP_VIDEO_RECORDING
    [_recorder previewViewFrameChanged];
#endif
}

#pragma mark 描画開始前
- (void)viewWillAppear:(BOOL)animated {
    
    deleteUserInsertedData = true;
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self prepareSession];
    
<<<<<<< HEAD
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
    [[FirstalertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [FirstalertView show];
=======
>>>>>>> beeff99c4a93b72c48a61e3a73d3e8947d1ea3c4
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
    
#if !TARGET_IPHONE_SIMULATOR && !defined SKIP_VIDEO_RECORDING
    [_recorder startRunning];
#else
    
    // yes this is very ugly :) (well its not in live code, only debugging, and will be rewritten some day)
    static bool hack = true;
    
    if (hack) {
        [self showVideo];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    // oh sweet jesus...
    hack = !hack;
    

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
    if (deleteUserInsertedData) {
        [VideoPostPreparation resetPostData];
    }
    deleteUserInsertedData = true;
    
    [super viewDidDisappear:animated];
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
    
#if !TARGET_IPHONE_SIMULATOR && !defined SKIP_VIDEO_RECORDING
    [self.focusView showFocusAnimation];
#endif
}


- (void)recorderDidEndFocus:(SCRecorder *)recorder {
    
#if !TARGET_IPHONE_SIMULATOR && !defined SKIP_VIDEO_RECORDING
    [self.focusView hideFocusAnimation];
#endif
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {
    
#if !TARGET_IPHONE_SIMULATOR && !defined SKIP_VIDEO_RECORDING
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
    
    NSLog(@"updateTimeRecordedLabel called");
    
    //self.tapView.hidden = NO;
    
    CMTime currentTime = kCMTimeZero;
    
    NSTimeInterval time_now = 0.0;
    NSTimeInterval time_max = RECORD_SECONDS;
    
#if !TARGET_IPHONE_SIMULATOR && !defined SKIP_VIDEO_RECORDING
    if (_recorder.session != nil) {
        NSLog(@"duration設定");
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
    
    NSLog(@"SCRecorderView now:%f,max:%f",time_now,time_max);
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
    informationController* evc = [informationController new];
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
    
<<<<<<< HEAD
    // POST API　GETも試してみる
    [APIClient  POST:movieFileForAPI
             rest_id:rest_id
          cheer_flag:cheertag value:valueKakaku category_id:category tag_id:atmosphere memo:comment handler:^(id result, NSUInteger code, NSError *error)
     {
         LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
         
         if (error){
             NSLog(@"post api失敗");
         }
         if ([result[@"code"] integerValue] == 200) {
             //[[self viewControllerSCPosting] afterRecording:[self viewControllerSCPosting]];
             
             //S3 upload
             //ファイル名+user_id形式
             NSString *movieFileForS3 = [NSString stringWithFormat:@"%@_%@.mp4",[[NSUserDefaults standardUserDefaults] valueForKey:@"post_time"],[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
             
             AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             
             //Transfermanagerの起動
             /*
             AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
             
             AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
             uploadRequest.bucket = @"gocci.movies.bucket.jp";
             uploadRequest.key = movieFileForS3;
             uploadRequest.body = dele.assetURL; //日付_ユーザーID.mp4
             uploadRequest.contentType = @"video/mp4";
             uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (totalBytesExpectedToSend > 0) {
                         NSLog(@"progress:%f",(float)((double) totalBytesSent / totalBytesExpectedToSend));
                     }
                 });
             };
              */
             NSURL *fileURL = dele.assetURL;
             
             AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
             expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"progress:%f",(float)((double) totalBytesSent / totalBytesExpectedToSend));
                 });
             };
             
             AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // Do something e.g. Alert a user for transfer completion.
                     // On failed uploads, `error` contains the error object.
                 });
             };
             
             AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
             [[transferUtility uploadFile:fileURL
                                   bucket:@"gocci.movies.bucket.jp"
                                      key:movieFileForS3
                              contentType:@"video/mp4"
                               expression:expression
                         completionHander:completionHandler] continueWithBlock:^id(AWSTask *task) {
                 if (task.error) {
                     NSLog(@"Error: %@", task.error);
                 }
                 if (task.exception) {
                     NSLog(@"Exception: %@", task.exception);
                 }
                 if (task.result) {
                     AWSS3TransferUtilityUploadTask *uploadTask = task.result;
                     NSLog(@"success:%@",uploadTask);
                     // Do something with uploadTask.
                 }
                 
                 return nil;
             }];

             //[self upload:uploadRequest];
             
             //Initiarize
             appDelegate.stringTenmei = @"";
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
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             [SVProgressHUD dismiss];
         }
     }];


=======
    [self DeleteDraft];
    /*
}else {
        UIAlertView *checkDelete  =[[UIAlertView alloc] initWithTitle:@"終了してよろしいですか？" message:@"撮影中の動画が削除されてしまいます" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        checkDelete.tag=121;
        [checkDelete show];
    }
     */
>>>>>>> beeff99c4a93b72c48a61e3a73d3e8947d1ea3c4
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
    deleteUserInsertedData = false;
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

    if (NSClassFromString(@"UIBlurEffect")) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        popupController.backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    }
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:17] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

#pragma mark - 撮影に戻る
- (IBAction)onGoPosting:(id)sender {
#ifdef DEBUG
#endif
}
@end