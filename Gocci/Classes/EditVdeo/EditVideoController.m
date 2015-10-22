//
//  EditVideoController.m
//  Gocci
//
//  Created by Castela on 2015/10/12.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "EditVideoController.h"
#import "AppDelegate.h"
#import "APIClient.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import "STPopup.h"
#import "RestPopupViewController.h"
#import "ValuePopupViewController.h"
#import "CategoryPopupViewController.h"
#import "LocationClient.h"

@interface EditVideoController ()

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;
@property (weak, nonatomic) IBOutlet UILabel *timeZone;
@property (weak, nonatomic) IBOutlet UILabel *restName;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
//posting
@property (weak,nonatomic)NSString *category_id;


@end

@implementation EditVideoController


- (void)dealloc {
   // [self.filterSwitcherView removeObserver:self forKeyPath:@"selectedFilter"];
    self.filterSwitcherView = nil;
    [_player pause];
    _player = nil;
    [self cancelSaveToCameraRoll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (SCFilter *)createAnimatedFilter {
    SCFilter *animatedFilter = [SCFilter emptyFilter];
    animatedFilter.name = @"Animated Filter";
    
    SCFilter *gaussian = [SCFilter filterWithCIFilterName:@"CIGaussianBlur"];
    SCFilter *blackAndWhite = [SCFilter filterWithCIFilterName:@"CIColorControls"];
    
    [animatedFilter addSubFilter:gaussian];
    [animatedFilter addSubFilter:blackAndWhite];
    
    double duration = 0.5;
    double currentTime = 0;
    BOOL isAscending = YES;
    
    Float64 assetDuration = CMTimeGetSeconds(_recordSession.assetRepresentingSegments.duration);
    
    while (currentTime < assetDuration) {
        if (isAscending) {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@1 endValue:@0 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@0 endValue:@10 startTime:currentTime duration:duration];
        } else {
            [blackAndWhite addAnimationForParameterKey:kCIInputSaturationKey startValue:@0 endValue:@1 startTime:currentTime duration:duration];
            [gaussian addAnimationForParameterKey:kCIInputRadiusKey startValue:@10 endValue:@0 startTime:currentTime duration:duration];
        }
        
        currentTime += duration;
        isAscending = !isAscending;
    }
    
    return animatedFilter;
}
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    self.exportView.clipsToBounds = YES;
    self.exportView.layer.cornerRadius = 20;
    */
    
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
    //do something like background color, title, etc you self
    [self.view addSubview:navbar];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"撮り直し" style:UIBarButtonItemStyleDone target:self action:@selector(Back)];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"シェア"];
    item.leftBarButtonItem = backBtn;
    [navbar pushNavigationItem:item animated:NO];
    
    _player = [SCPlayer player];
    /*
    if ([[NSProcessInfo processInfo] activeProcessorCount] > 1) {
        self.filterSwitcherView.refreshAutomaticallyWhenScrolling = NO;
        self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFill;
        
        SCFilter *emptyFilter = [SCFilter emptyFilter];
        emptyFilter.name = @"#nofilter";
        
        self.filterSwitcherView.filters = @[
                                            emptyFilter,
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectNoir"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectChrome"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectTonal"],
                                            [SCFilter filterWithCIFilterName:@"CIPhotoEffectFade"],
                                            // Adding a filter created using CoreImageShop
                                            [SCFilter filterWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"a_filter" withExtension:@"cisf"]],
                                            [self createAnimatedFilter]
                                            ];
        _player.CIImageRenderer = self.filterSwitcherView;
        [self.filterSwitcherView addObserver:self forKeyPath:@"selectedFilter" options:NSKeyValueObservingOptionNew context:nil];
    } else {
     */
        SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
        playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        playerView.frame = self.filterSwitcherView.frame;
       // playerView.autoresizingMask = self.filterSwitcherView.autoresizingMask;
        [self.filterSwitcherView.superview insertSubview:playerView aboveSubview:self.filterSwitcherView];
        [self.filterSwitcherView removeFromSuperview];
   // }
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (delegate.stringTenmei) {
    NSString *restname_str = @"店名：";
  _restName.text = [restname_str stringByAppendingString:delegate.stringTenmei];
    }else{
        _restName.text = @"店名：";
    }
    if (delegate.stringCategory){
        NSString *category_str = @"カテゴリー：";
        _category.text =  [category_str stringByAppendingString:delegate.stringCategory];
    }else{
        _category.text = @"カテゴリー：";
    }
    if (delegate.valueKakaku){
        NSString *value_str = @"価格：";
        NSString *valueStr = [delegate.valueKakaku stringByAppendingString:@"円"];
        _value.text = [value_str stringByAppendingString:valueStr];
    }else{
        _value.text = @"価格：";
    }
    _player.loopEnabled = YES;
    // [デリゲートの設定]
    _textView.delegate = self;
    // [「改行（Return）」キーの設定]
    _textView.returnKeyType = UIReturnKeyDone;
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    NSLog(@"player:%@",_recordSession);
    [self infoUpdate];
    [_player play];
}

//[self saveToCameraRoll];

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

- (IBAction)shareButton:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.stringTenmei != nil &&[appDelegate.stringTenmei length]>0) {
        [self saveToCameraRoll];
    }else{
      [[[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"店名が未入力です" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.filterSwitcherView) {
        self.filterNameLabel.hidden = NO;
        self.filterNameLabel.text = self.filterSwitcherView.selectedFilter.name;
        self.filterNameLabel.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.filterNameLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.3 delay:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    self.filterNameLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }];
    }
}
*/

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCEditVideoViewController class]]) {
        SCEditVideoViewController *editVideo = segue.destinationViewController;
        editVideo.recordSession = self.recordSession;
    }
}
 */


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (error == nil) {
        
        NSLog(@"contextInfo:%@,videopath:%@",contextInfo,videoPath);
        NSLog(@"execsubmit");
        //Cheertag
        int cheertag = 1;
        if (appDelegate.cheertag) cheertag = appDelegate.cheertag;
        //Value
        NSString *valueKakaku = @"";
        if (appDelegate.valueKakaku) valueKakaku = appDelegate.valueKakaku;
        /*
         //Atmosphere
         NSString *atmosphere = @"1";
         if (appDelegate.stringFuniki) atmosphere = appDelegate.stringFuniki;
         */
        //Category
        NSString *category = @"1";
        // NSLog(@"雰囲気は:%@",appDelegate.stringFuniki);
        if (appDelegate.indexCategory) category= appDelegate.indexCategory;
        //Comment
        NSString *comment = @"none";
        NSLog(@"カテゴリーは:%@",appDelegate.stringCategory);
        if (appDelegate.valueHitokoto) comment = appDelegate.valueHitokoto;
        //Restid
        NSString *rest_id = @"...";
        if (appDelegate.indexTenmei) rest_id = appDelegate.indexTenmei;
        
        NSString *movieFileForAPI = [NSString stringWithFormat:@"%@_%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"post_time"],[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
        
        //TODO change post api client
    
        [APIClient POST:movieFileForAPI rest_id:rest_id cheer_flag:cheertag value:valueKakaku
            category_id:category tag_id:@"" memo:comment handler:^(id result, NSUInteger code, NSError *error)
         
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
         
             NSLog(@"movieFileForS3:%@",movieFileForS3);
             
         AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         
         NSURL *fileURL = dele.assetURL;
         NSLog(@"assetURL:%@",dele.assetURL);
             
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
                     NSLog(@"success:%@",uploadTask);
                     // Do something with uploadTask.
                 }
                 
                 return nil;
             }];
         
                  
         //Initiarize
         appDelegate.stringTenmei = @"";
         appDelegate.indexTenmei = @"";
         appDelegate.valueHitokoto = @"";
         appDelegate.stringCategory = @"";
         appDelegate.indexCategory = @"";
         appDelegate.valueKakaku = @"";
             
         }
         }];
        
    } else {
        /*
        [[[UIAlertView alloc] initWithTitle:@"保存失敗しました" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         */
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    if ([text isEqualToString:@"\n"]) {
        // ここにtextのデータ(記録)処理など
        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        delegate.valueHitokoto = textView.text;
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
    // YES if the old text should be replaced by the new text;
    // NO if the replacement operation should be aborted. (Apple's Reference より)
}

// 編集開始
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"編集開始");
    [self performSelector:@selector(setCursorToBeginning:) withObject:textView afterDelay:0.01];

    if ([_placeholder.text isEqualToString:@"コメントを書く"]) {
        _placeholder.text = @"";
    }
}

- (void)setCursorToBeginning:(UITextView *)textView
{
    //you can change first parameter in NSMakeRange to wherever you want the cursor to move
    textView.selectedRange = NSMakeRange(3, 0);
}

// 編集終了
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_textView.text isEqualToString:@""]) {
        _placeholder.text = @"コメントを書く";
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // ここにtextデータの処理
    // キーボードを閉じる
    [self.textView resignFirstResponder];
}

/*
- (void)assetExportSessionDidProgress:(SCAssetExportSession *)assetExportSession {
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = assetExportSession.progress;
        
        CGRect frame =  self.progressView.frame;
        frame.size.width = self.progressView.superview.frame.size.width * progress;
        self.progressView.frame = frame;
    });
}
*/

- (void)cancelSaveToCameraRoll
{
    [_exportSession cancelExport];
}

- (IBAction)cancelTapped:(id)sender {
    [self cancelSaveToCameraRoll];
}

- (void)saveToCameraRoll {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    SCFilter *currentFilter = [self.filterSwitcherView.selectedFilter copy];
    
    [_player pause];
    
    SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingSegments];
    exportSession.videoConfiguration.filter = currentFilter;
    exportSession.videoConfiguration.preset = SCPresetHighestQuality;
    exportSession.audioConfiguration.preset = SCPresetHighestQuality;
    exportSession.videoConfiguration.maxFrameRate = 35;
    exportSession.outputUrl = self.recordSession.outputUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.delegate = self;
    self.exportSession = exportSession;
    
    NSLog(@"urlは%@",exportSession.outputUrl);
    AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dele.assetURL = exportSession.outputUrl;
    
  //  [self performSegueWithIdentifier:@"Posting" sender:self];
    
    /*
    self.exportView.hidden = NO;
    self.exportView.alpha = 0;
    CGRect frame =  self.progressView.frame;
    frame.size.width = 0;
    self.progressView.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.exportView.alpha = 1;
    }];
    
    SCWatermarkOverlayView *overlay = [SCWatermarkOverlayView new];
    overlay.date = self.recordSession.date;
    exportSession.videoConfiguration.overlay = overlay;
    NSLog(@"Starting exporting");
    
    CFTimeInterval time = CACurrentMediaTime();
    __weak typeof(self) wSelf = self;
     */
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        //__strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
         //  NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
        /*
        if (strongSelf != nil) {
         
            [strongSelf.player play];
            strongSelf.exportSession = nil;
            strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
            
            [UIView animateWithDuration:0.3 animations:^{
                strongSelf.exportView.alpha = 0;
            }];
        }
         */
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            UISaveVideoAtPathToSavedPhotosAlbum(exportSession.outputUrl.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
    
}
- (IBAction)showBottomSheet:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)openEdit:(id)sender {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:[[UIStoryboard storyboardWithName:@"4_7_inch" bundle:nil] instantiateViewControllerWithIdentifier:@"BottomSheet"]];
    popupController.style = STPopupStyleBottomSheet;
    [popupController presentInViewController:self];
}

#pragma mark - 戻る
- (IBAction)popViewController1:(UIStoryboardSegue *)segue {
    
    NSLog(@"%s",__func__);

}

-(void)infoUpdate{
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([delegate.stringTenmei length]>0) {
        _restName.text = delegate.stringTenmei;
    }else{
        _restName.text = @"未入力";
    }
    if ([delegate.stringCategory length]>0){
        _category.text =  delegate.stringCategory;
    }else{
        _category.text = @"未入力";
    }
    if ([delegate.valueKakaku length]>0){
        _value.text = [delegate.valueKakaku stringByAppendingString:@"円"];
    }else{
        _value.text = @"未入力";
    }
    
}

- (IBAction)restnameInsert:(id)sender {
    [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[RestPopupViewController new]];
}

- (IBAction)valueInsert:(id)sender {

     [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[ValuePopupViewController new]];
}

- (IBAction)categoryInsert:(id)sender {
     [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[CategoryPopupViewController new]];
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
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Cochin" size:17] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}


@end
