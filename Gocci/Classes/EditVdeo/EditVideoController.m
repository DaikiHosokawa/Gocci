//
//  EditVideoController.m
//  Gocci
//
//  Created by Castela on 2015/10/12.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import "EditVideoController.h"
#import "AppDelegate.h"

@interface EditVideoController ()

@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;

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
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveToCameraRoll)];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(Back)];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"編集"];
    item.rightBarButtonItem = saveBtn;
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
    
    _player.loopEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    NSLog(@"player:%@",_recordSession);
    [_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
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
    
    if (error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"保存完了しました" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"保存失敗しました" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
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
    
    [self performSegueWithIdentifier:@"Posting" sender:self];
    
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

#pragma mark - 戻る
- (IBAction)popViewController1:(UIStoryboardSegue *)segue {
    
    NSLog(@"%s",__func__);

}

@end
