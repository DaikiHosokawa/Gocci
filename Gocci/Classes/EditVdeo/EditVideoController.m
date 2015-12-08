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
#import "BFPaperCheckbox.h"
#import "FullScreenViewController.h"
#import "UCZProgressView.h"
#import "Swift.h"
#import "TimelinePageMenuViewController.h"

@interface EditVideoController ()<BFPaperCheckboxDelegate>{
    NSString * cheertag_update;
}

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *restName;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
//posting
@property (weak,nonatomic)NSString *category_id;
@property (weak, nonatomic) IBOutlet BFPaperCheckbox *checkbox;
@property (nonatomic, copy) NSArray *checkboxes;
@property (weak, nonatomic) IBOutlet UCZProgressView *progressView;


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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
    //do something like background color, title, etc you self
    [self.view addSubview:navbar];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"撮り直し" style:UIBarButtonItemStyleDone target:self action:@selector(Back)];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"シェア"];
    item.leftBarButtonItem = backBtn;
    [navbar pushNavigationItem:item animated:NO];
    
    
    _player = [SCPlayer player];
    
    self.checkbox.delegate = self;
    self.checkbox.rippleFromTapLocation = NO;
    self.checkbox.tapCirclePositiveColor = [UIColor yellowColor]; // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    self.checkbox.tapCircleNegativeColor = [UIColor redColor];   // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    self.checkbox.checkmarkColor = [UIColor blueColor];
       SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerView.frame = self.filterSwitcherView.frame;
    // playerView.autoresizingMask = self.filterSwitcherView.autoresizingMask;
    [self.filterSwitcherView.superview insertSubview:playerView aboveSubview:self.filterSwitcherView];
    [self.filterSwitcherView removeFromSuperview];
    [playerView.superview insertSubview:self.coverView aboveSubview:playerView];
   
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(view_Tapped:)];
    
    [playerView addGestureRecognizer:tapGesture];
    
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
    
    self.progressView.hidden = YES;
    //self.progressView.progress = 0.0;
    self.progressView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
  self.progressView.showsText = YES;
    self.progressView.tintColor = [UIColor blackColor];
    self.progressView.usesVibrancyEffect = NO;
    self.progressView.textColor = [UIColor blackColor];
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
    if (![self.navigationController.viewControllers containsObject:self]) {
        //戻るを押された
        NSLog(@"back");
        [self.delegate retake];
    }
    
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
#ifdef INDEVEL
        appDelegate.stringTenmei = @"UNSPECIFIED";
        [self saveToCameraRoll];
#endif
    }
    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0;
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (error == nil) {
        
        NSLog(@"contextInfo:%@,videopath:%@",contextInfo,videoPath);
        NSLog(@"execsubmit");
        //Cheertag
        NSString *cheertag = @"0";
        if ([cheertag_update isEqualToString:@"1"]) cheertag = cheertag_update;
        //Value
        NSString *valueKakaku = @"";
        if ([appDelegate.valueKakaku length]>0) valueKakaku = appDelegate.valueKakaku;
        
        //Category
        NSString *category = @"1";
        // NSLog(@"雰囲気は:%@",appDelegate.stringFuniki);
        if ([appDelegate.indexCategory length]>0) category= appDelegate.indexCategory;
        //Comment
        NSString *comment = @"none";
        NSLog(@"カテゴリーは:%@",appDelegate.stringCategory);
        if ([appDelegate.valueHitokoto length]>0) comment = appDelegate.valueHitokoto;
        //Restid
        NSString *rest_id = @"...";
        if ([appDelegate.indexTenmei length]>0) rest_id = appDelegate.indexTenmei;
        
        NSString *movieFileForAPI = [NSString stringWithFormat:@"%@_%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"post_time"], Persistent.user_id];
        
        //TODO change post api client
        
        [APIClient POST:movieFileForAPI rest_id:rest_id cheer_flag:cheertag value:valueKakaku
            category_id:category tag_id:@"" memo:comment handler:^(id result, NSUInteger code, NSError *error)
         
         {
             
             LOG(@"result=%@, code=%@, error=%@", result, @(code), error);
             
             if (error){
                 NSLog(@"post api失敗");
                 self.progressView.progress = 1.0;
             }
             if ([result[@"code"] integerValue] == 200) {
                 //[[self viewControllerSCPosting] afterRecording:[self viewControllerSCPosting]];
                 
                 //S3 upload
                 //ファイル名+user_id形式
                 NSString *movieFileForS3 = [NSString stringWithFormat:@"%@_%@.mp4",[[NSUserDefaults standardUserDefaults] valueForKey:@"post_time"], Persistent.user_id];
                 
                 NSLog(@"movieFileForS3:%@",movieFileForS3);
                 
                 AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                 
                 NSURL *fileURL = dele.assetURL;
                 NSLog(@"assetURL:%@",dele.assetURL);
                 
                 AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
                 expression.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSLog(@"progress:%f",(float)((double) totalBytesSent / totalBytesExpectedToSend));
                         self.progressView.progress = (float)((double) totalBytesSent / totalBytesExpectedToSend);
                        
                         if (self.progressView.progress >= 1) {
                             NSLog(@"完了");
                             //Initiarize
                             appDelegate.stringTenmei = @"";
                             appDelegate.indexTenmei = @"";
                             appDelegate.valueHitokoto = @"";
                             appDelegate.stringCategory = @"";
                             appDelegate.indexCategory = @"";
                             appDelegate.valueKakaku = @"";
                             [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
                         }

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
                         self.progressView.progress = 1.0;
                         [[[UIAlertView alloc] initWithTitle:@"通信に失敗しました" message:@"電波状況の良い場所で再度シェアを押してください" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                     }
                     if (task.exception) {
                         NSLog(@"Exception: %@", task.exception);
                         self.progressView.progress = 1.0;
                         [[[UIAlertView alloc] initWithTitle:@"通信に失敗しました" message:@"電波状況の良い場所で再度シェアを押してください" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                     }
                     if (task.result) {
                         AWSS3TransferUtilityUploadTask *uploadTask = task.result;
                         NSLog(@"success:%@",uploadTask);
                                                  // Do something with uploadTask.
                     }
                     
                     return nil;
                 }];
                 
                 
             }else{
                 self.progressView.progress = 1.0;
                 [[[UIAlertView alloc] initWithTitle:@"通信に失敗しました" message:@"電波状況の良い場所で再度シェアを押してください" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             }
         }];
        
    } else {
        [[[UIAlertView alloc] initWithTitle:@"通信に失敗しました" message:@"電波状況の良い場所で再度シェアを押してください" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

- (void)paperCheckboxChangedState:(BFPaperCheckbox *)changedCheckbox
{
    if (changedCheckbox.isChecked) {
        NSLog(@"選択");
        cheertag_update = @"1";
    }else{
        NSLog(@"解除");
        cheertag_update = @"0";
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // ここにtextデータの処理
    // キーボードを閉じる
    [self.textView resignFirstResponder];
}




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
   
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        //__strong typeof(self) strongSelf = wSelf;
        
        if (!exportSession.cancelled) {
            //  NSLog(@"Completed compression in %fs", CACurrentMediaTime() - time);
        }
   
        
        NSError *error = exportSession.error;
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
        } else if (error == nil) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            NSLog(@"CCCCCCCCCCCCCCCCCCCCCCCC:");
            NSLog(exportSession.outputUrl.path);
            UISaveVideoAtPathToSavedPhotosAlbum(exportSession.outputUrl.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        } else {
            if (!exportSession.cancelled) {
                [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }];
    
}
#pragma mark - 戻る
- (IBAction)popViewController1:(UIStoryboardSegue *)segue {
    
    NSLog(@"%s",__func__);
    
}

-(void)infoUpdate{
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([delegate.stringTenmei length]>0) {
        _restName.text = delegate.stringTenmei;
    }
    else{
        _restName.text = @"未入力";
    }
    
    if ([delegate.stringCategory length]>0){
        _category.text =  delegate.stringCategory;
    }
    else{
        _category.text = @"未入力";
    }
    
    if ([delegate.valueKakaku length]>0){
        _value.text = [delegate.valueKakaku stringByAppendingString:@"円"];
    }
    else{
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[FullScreenViewController class]]) {
        FullScreenViewController  *FullScreen = segue.destinationViewController;
        FullScreen.recordSession = _recordSession;
    }
}

- (void)view_Tapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"タップされました．");
    [self performSegueWithIdentifier:@"Full" sender:self];
}

@end
