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
#import "EditVideoController.h"
#import "SCImageDisplayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import "SCSessionListViewController.h"
#import "SCRecordSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RestaurantTableViewController.h"
//#import "GaugeView.h"¥
#import "APIClient.h"
#import "SCPostingViewController.h"
#import "SVProgressHUD.h"
#import "SCScrollPageView.h"

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#define kVideoPreset AVCaptureSessionPresetHigh

// !!!:dezamisystem
static NSString * const SEGUE_GO_KAKAKUTEXT = @"goKakaku";
static NSString * const SEGUE_GO_BEFORE_RECORDER = @"goBeforeRecorder";
static NSString * const SEGUE_GO_POSTING = @"goPosting";
static NSString * const SEGUE_GO_HITOKOTO = @"goHitokoto";

static SCRecordSession *staticRecordSession;	// !!!:開放を避けるためにスタティック化

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCRecorderViewController ()
{
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
    
    NSTimer *timerRecord;
    NSTimeInterval test_timeGauge;
    
    // !!!:dezamisystem・スクロールページ用
    SCScrollPageView *scrollpageview;

}

@property (weak, nonatomic) IBOutlet UIView *viewPageBase;


@property (strong, nonatomic) SCRecorderToolsView *focusView;

// !!!:dezamisystem・スクロールページ用
//@property (nonatomic,strong) UIScrollView *pageingScrollView;
@property(nonatomic,strong) SCFirstView *firstView;
@property(nonatomic,strong) SCSecondView *secondView;
//@property (nonatomic, strong) SCRecordSession *recordSession;	// !!!:開放を避けるためにスタティック化
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewPage;

@property (weak, nonatomic) IBOutlet UIButton *retakeBtn;

@property (weak, nonatomic) IBOutlet UIButton *reverseBtn;

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
    _recorder.captureSessionPreset = AVCaptureSessionPreset640x480;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder.initializeSessionLazily = NO;
    
    //	[self updateTimeRecordedLabel];
    
    _recorder.maxRecordDuration = CMTimeMake(4200, 600);
    
    UIView *previewView = self.view; // self.previewView;
    _recorder.previewView = previewView;
    
 
    //	self.loadingView.hidden = YES;
    //CGRect rect_focus = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //NSLog(@"フォーカス矩形：%@", NSStringFromCGRect(rect_focus) );
    self.focusView = [[SCRecorderToolsView alloc] initWithFrame:previewView.bounds];
    self.focusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    [self.focusView addSubview:self.retakeBtn];
    [self.focusView addSubview:self.reverseBtn];
    
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
        //[self updateTimeRecordedLabel];

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
   
    [self prepareSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder stopRunning];
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
    //	[self.viewIndicator stopAnimating];
#endif
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
        videoPlayer.recordSession = _recordSession;
    }
}

-(void)recordBegan
{
    [_recorder record];
    NSLog(@"おささる");
}
-(void)recordEnded
{
    [_recorder pause];
    NSLog(@"お刺さらない");
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
    NSTimeInterval time_max = 7.0;
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
    
    //currentTimelをラベルに表示する
    //    self.timeRecordedLabel.text = [NSString stringWithFormat:@"%.1f 秒", time_now];
    
    NSLog(@"now:%f,max:%f",time_now,time_max);
    // !!!:・円グラフゲージ
    [firstView updatePieChartWith:time_now MAX:time_max];
    
}





#pragma mark - RecorderSubmitPopupViewDelegate
#pragma mark Twitter へ投稿
/*
 - (void)recorderSubmitPopupViewOnTwitterShare
 {

 }
 */

#pragma mark Facebook へ投稿
/*
- (void)recorderSubmitPopupViewOnFacebookShare:(UIViewController *)viewcontroller
{
    
}
*/


#pragma mark - Private Methods

#pragma mark Complete撮影完了処理

/**
 *  撮影完了処理
 */
/*
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
*/

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

-(void)flipCamera
{
    [_recorder switchCaptureDevices];
}
-(void)DeleteDraft
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)retake
{
    SCRecordSession *recordSession = _recorder.session;
    
    if (recordSession != nil) {
        _recorder.session = nil;
        
        // If the recordSession was saved, we don't want to completely destroy it
        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
            [recordSession endSegmentWithInfo:nil completionHandler:nil];
        } else {
            [recordSession cancelSession:nil];
        }
    }
    
    [self prepareSession];
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
             NSLog(@"post api失敗");
         }
         if ([result[@"code"] integerValue] == 200) {
             //[[self viewControllerSCPosting] afterRecording:[self viewControllerSCPosting]];
             
             //S3 upload
             //ファイル名+user_id形式
             NSString *movieFileForS3 = [NSString stringWithFormat:@"%@_%@.mp4",[[NSUserDefaults standardUserDefaults] valueForKey:@"post_time"],[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
             
             AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             
             NSURL *fileURL = dele.assetURL;
             
             AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
             expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSLog(@"progress:%f",(float)((double) totalBytesSent / totalBytesExpectedToSend));
                 });
             };
             
             AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                    // [self deleteTmpCaptureDir];
                 });
             };
        
             AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility S3TransferUtilityForKey:@"gocci_up_north_east_1"];
             [[transferUtility uploadFile:fileURL
                                   bucket:@"gocci.movies.bucket.jp-test"
                                      key:movieFileForS3
                              contentType:@"video/quicktime"
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
                     NSLog(@"success:%@",task.result);
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


}

/*
- (void)deleteTmpCaptureDir
{
    
    AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *fileURL = dele.assetURL;
    NSString *fileName = [fileURL lastPathComponent];
    
    NSLog(@"filename :%@",fileName);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    // ~/tmpディレクトリの取得
    NSString *tmpDir = NSTemporaryDirectory();
    // tmpディレクトリ内の一覧取得
    NSArray *list = [manager contentsOfDirectoryAtPath:tmpDir error:&error];
    NSLog(@"list:%@",list);
    // 一覧の中から「capture」を含むディレクトリ・ファイルを検索
    for (NSString *path in list) {
        NSRange range = [path rangeOfString:fileName];
        // 存在したならば削除
        if (NSNotFound != range.location) {
            NSLog(@"存在");
            NSString *target = [tmpDir stringByAppendingPathComponent:path];
            [manager removeItemAtPath:target error:&error];
        }
    }
}
 */


#pragma mark - 撮り直し
- (IBAction)onRetake:(id)sender {
    NSLog(@"osareteru1");
    [self retake];
}

- (IBAction)onReverse:(id)sender {
   NSLog(@"osareteru2");
    [_recorder switchCaptureDevices];
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

#pragma mark - 撮影に戻る
- (IBAction)onGoPosting:(id)sender {
#ifdef DEBUG
    //	[self performSegueWithIdentifier:SEGUE_GO_POSTING sender:self];
#endif
}
@end