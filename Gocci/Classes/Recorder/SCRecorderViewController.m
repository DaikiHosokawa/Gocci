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

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSSQS/AWSSQS.h>
#import <AWSSNS/AWSSNS.h>
#import <AWSCognito/AWSCognito.h>

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
<RecorderSubmitPopupViewDelegate ,RecorderSubmitPopupAdditionViewDelegate>
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
    
 
    //	self.loadingView.hidden = YES;
    CGRect rect_focus = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //NSLog(@"フォーカス矩形：%@", NSStringFromCGRect(rect_focus) );
    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:rect_focus];
    self.focusView.recorder = _recorder;
    [self.view addSubview:self.focusView];
    [self.view sendSubviewToBack:self.focusView];
    
    // 現在時間を取得する
    NSDate *now = [NSDate date];
    NSLog(@"%@", now);
    
    // 日付のフォーマット
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
    NSString *nowString = [formatter stringFromDate:now];
    [[NSUserDefaults standardUserDefaults] setValue:nowString forKey:@"post_time"];
    
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
/*
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
 */

#pragma mark Facebook へ投稿

- (void)recorderSubmitPopupViewOnFacebookShare:(UIViewController *)viewcontroller
{
    LOG_METHOD;
    
    
    NSURL *videoURL = staticRecordSession.outputUrl;
    FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
    video.videoURL = videoURL;
    FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
    content.video = video;
    [FBSDKShareDialog showFromViewController:viewcontroller
                                 withContent:content
                                    delegate:nil];
    
    /*
     FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc] init];
     content.contentURL = staticRecordSession.outputUrl;
     content.contentDescription = @"test";
     content.contentTitle = @"New Post";
     BOOL ok = [[FBSDKShareAPI shareWithContent:content delegate:self] share];
     */
    /*
     FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc]init];
     shareDialog.fromViewController = viewcontroller;
     NSURL *videoURL= delegate.assetURL;
     NSLog(@"assetURL:%@",delegate.assetURL);
     FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
     video.videoURL = videoURL;
     FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
     content.video = video;
     shareDialog.shareContent = content;
     shareDialog.delegate=self;
     [shareDialog show];
     */
}




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

#pragma mark Complete撮影完了処理
/**
 *  撮影完了処理
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
#pragma mark 投稿するボタンを押した時
-(void)execSubmit
{
    
    
    //ファイル名+user_id形式
    NSString *movieFileForS3 = [NSString stringWithFormat:@"%@_%@.mp4",[[NSUserDefaults standardUserDefaults] valueForKey:@"post_time"],[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
    
    AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Transfermanagerの起動
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"gocci.movies.bucket.jp-test";
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

    [self upload:uploadRequest];

}





#pragma mark - 戻る
- (IBAction)popViewController1:(UIStoryboardSegue *)segue {

    NSLog(@"%s",__func__);
    
    [self retake];
}

#pragma mark - 撮り直し
- (IBAction)onRetake:(id)sender {
    
    [self retake];
}


#pragma mark - 撮影に戻る
- (IBAction)onGoPosting:(id)sender {
#ifdef DEBUG
    //	[self performSegueWithIdentifier:SEGUE_GO_POSTING sender:self];
#endif
}

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        NSLog(@"upload start:%@",task);
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                        });
                    }
                        break;
                        
                    default:
                        NSLog(@"Upload failed: [%@]", task.error);
                        break;
                }
            } else {
                NSLog(@"Upload failed: [%@]", task.error);
            }
        }
        
        if (task.result) {
            
                    [SVProgressHUD show];
                    
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
                   //APIに送信
            
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    //Cheertag
                    int cheertag = 1;
                    if (appDelegate.cheertag) cheertag = appDelegate.cheertag;
                    //Value
                    int valueKakaku = 0;
                    if (appDelegate.valueKakaku) valueKakaku = appDelegate.valueKakaku;
                    //Atmosphere
                    NSString *atmosphere = @"1";
                    if (appDelegate.stringFuniki) atmosphere = appDelegate.stringFuniki;
                    //Category
                    NSString *category = @"1";
                    NSLog(@"雰囲気は:%@",appDelegate.stringFuniki);
                    if (appDelegate.stringCategory) category= appDelegate.stringCategory;
                    //Comment
                    NSString *comment = @"none";
                    NSLog(@"カテゴリーは:%@",appDelegate.stringCategory);
                    if (appDelegate.valueHitokoto) comment = appDelegate.valueHitokoto;
                    //Restid
                    NSString *rest_id = @"...";
                    if (appDelegate.rest_id) rest_id = appDelegate.rest_id;
                    
                    NSString *movieFileForAPI = [NSString stringWithFormat:@"%@_%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"post_time"],[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
                    
                    // POST API　GETも試してみる
                    [APIClient  POST:movieFileForAPI
                             rest_id:rest_id
                          cheer_flag:cheertag value:valueKakaku category_id:category tag_id:atmosphere memo:comment handler:^(id result, NSUInteger code, NSError *error)
                     {
                         LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
                         
                         if (error){
                             
                         }
                         if ([result[@"code"] integerValue] == 200) {
                               [[self viewControllerSCPosting] afterRecording:[self viewControllerSCPosting]];
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
                             
                             [SVProgressHUD dismiss];
                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         }
                     }];

        }
        
        return nil;
    }];
}

#pragma mark - 取得
-(SCPostingViewController*)viewControllerSCPosting
{
    static NSString * const namebundle = @"scposting";
    
    SCRecorderViewController* viewController = nil;
    {
        CGRect rect = [UIScreen mainScreen].bounds;
        if (rect.size.height == 480) {
            // ストーリーボードを取得
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"3_5_inch" bundle:nil];
            //ビューコントローラ取得
            viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
        }
        else if (rect.size.height == 667) {
            // ストーリーボードを取得
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil];
            //ビューコントローラ取得
            viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
        }
        else if (rect.size.height == 736) {
            // ストーリーボードを取得
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"5_5_inch" bundle:nil];
            //ビューコントローラ取得
            viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
        }
        else {
            // ストーリーボードを取得
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //ビューコントローラ取得
            viewController = [storyboard instantiateViewControllerWithIdentifier:namebundle];
        }
    }
    
    return viewController;
}


@end
