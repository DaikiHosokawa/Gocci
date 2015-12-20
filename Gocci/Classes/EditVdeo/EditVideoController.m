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
#import "RestAddPopupViewController.h"
#import "ValuePopupViewController.h"
#import "CategoryPopupViewController.h"
#import "requestGPSPopupViewController.h"
#import "LocationClient.h"
#import "BFPaperCheckbox.h"
#import "FullScreenViewController.h"
#import "Swift.h"
#import "requestGPSPopupViewController.h"
#import "TimelinePageMenuViewController.h"

@interface EditVideoController ()<BFPaperCheckboxDelegate>{
    NSString * cheertag_update;
    CLLocationManager* locationManager;
}


@property (strong, nonatomic) SCAssetExportSession *exportSession;
@property (strong, nonatomic) SCPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *restName;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;

@property (weak,nonatomic)NSString *category_id;
@property (weak, nonatomic) IBOutlet BFPaperCheckbox *checkbox;
@property (weak, nonatomic) IBOutlet BFPaperCheckbox *TwitterCheckbox;
@property (weak, nonatomic) IBOutlet UIButton *TwitterComment;
@property (nonatomic, copy) NSArray *checkboxes;


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


//             UISaveVideoAtPathToSavedPhotosAlbum(exportSession.outputUrl.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
// - (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {%

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
    
    UIColor *color_custom = [UIColor colorWithRed:247./255. green:85./255. blue:51./255. alpha:1.];
    self.checkbox.rippleFromTapLocation = NO;
    self.checkbox.tapCirclePositiveColor = [UIColor blackColor];
    self.checkbox.tapCircleNegativeColor = [UIColor blackColor];
    self.checkbox.checkmarkColor = color_custom;
    
    
    UIColor *color_twitter = [UIColor colorWithRed:85./255. green:172./255. blue:238./255. alpha:1.];
    self.TwitterCheckbox.rippleFromTapLocation = NO;
    self.TwitterCheckbox.tapCirclePositiveColor = [UIColor blackColor];
    self.TwitterCheckbox.tapCircleNegativeColor = [UIColor blackColor];
    self.TwitterCheckbox.checkmarkColor = color_twitter;
    self.TwitterCheckbox.tag = 1001;
    self.TwitterCheckbox.delegate = self;
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
    
    
    _restName.text = ([VideoPostPreparation.postData.rest_name isEqual:@""]) ? @"未入力" : VideoPostPreparation.postData.rest_name;
    VideoPostPreparation.postData.notifyNewRestName = ^(NSString * newRestName) {
        _restName.text = newRestName;
    };
    
    _value.text = ([VideoPostPreparation.postData.value isEqual:@""]) ? @"未入力" : VideoPostPreparation.postData.value;
    VideoPostPreparation.postData.notifyNewPrice = ^(NSString * newPrice) {
        _value.text = newPrice;
    };
    
    _category.text = ([VideoPostPreparation.postData.category_string isEqual:@""]) ? @"未入力" : VideoPostPreparation.postData.category_string;
    VideoPostPreparation.postData.notifyNewCategory = ^(NSString * newCat) {
        _category.text = newCat;
    };
    
    
    _player.loopEnabled = YES;
    _player.muted = YES;
    _textView.delegate = self;
    _textView.returnKeyType = UIReturnKeyDone;
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:_recordSession.assetRepresentingSegments];
    NSLog(@"player:%@",_recordSession);
    [_player play];
}

-(void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox{
    if (checkbox == self.TwitterCheckbox) {
        self.TwitterComment.hidden = !checkbox.isChecked;
        
        if (checkbox.isChecked) {
            [Bridge authenticateWithTwitterIfNecessary:self];
        }
        
        NSString *possibleTweet = [NSString stringWithFormat:@"%@ %@", GOCCI_TWITTER_TAG, self.textView.text];
        
        // tweet below 120 char limit
        if (checkbox.isChecked && [Bridge videoTweetMessageRemainingCharacters:possibleTweet] >= 0) {
            VideoPostPreparation.postData.postOnTwitter = YES;
        }
        // maybe without the gocci hashtag
        else if (checkbox.isChecked && [Bridge videoTweetMessageRemainingCharacters:self.textView.text] >= 0) {
            VideoPostPreparation.postData.postOnTwitter = YES;
        }
        // Tweet too long
        else if (checkbox.isChecked){
            [TwitterPopupBridge pop:self initialTweet:possibleTweet];
        }
        else {
            VideoPostPreparation.postData.postOnTwitter = NO;
        }
    }
}
- (IBAction)TwitterCommentEdit:(id)sender {
    
    if (![VideoPostPreparation.postData.twitterTweetMsg isEqual:@""]) {
        [TwitterPopupBridge pop:self initialTweet:VideoPostPreparation.postData.twitterTweetMsg];
    }
    else {
        NSString *possibleTweet = [NSString stringWithFormat:@"%@ %@", GOCCI_TWITTER_TAG, self.textView.text];
        [TwitterPopupBridge pop:self initialTweet:possibleTweet];
    }
}

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
    

    
    if (VideoPostPreparation.postData.postOnTwitter && [VideoPostPreparation.postData.twitterTweetMsg isEqual:@""]) {
        NSString *tweet = [NSString stringWithFormat:@"%@ %@", GOCCI_TWITTER_TAG, self.textView.text];

        if ([Bridge videoTweetMessageRemainingCharacters:tweet] >= 0) {
            VideoPostPreparation.postData.twitterTweetMsg = tweet;
        }
        else if ([Bridge videoTweetMessageRemainingCharacters:self.textView.text] >= 0) {
            VideoPostPreparation.postData.twitterTweetMsg = self.textView.text;
        }
        else {
            // this only happen if the user edit the main text, after clicking the twitter share button
            // to prevent he posts the wrong msg on twitter
            
            [TwitterPopupBridge pop:self initialTweet:VideoPostPreparation.postData.twitterTweetMsg];
            return; // TODO <- the user has to click again on share, not good
        }
    }
    
//    // that is kinda ugly. make this better one day
//    if ([self.textView.text isEqual:@""] && [VideoPostPreparation.postData.twitterTweetMsg isEqual:@""]) {
//        VideoPostPreparation.postData.twitterTweetMsg = GOCCI_TWITTER_TAG;
//    }
    
    
    
    if (![VideoPostPreparation isReadyToSend])
    {
        [[[UIAlertView alloc] initWithTitle:@"お知らせ" message:@"店名が未入力です" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
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
    
    
    
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (exportSession.cancelled) {
            NSLog(@"Export was cancelled");
            return;
        }
        else if (exportSession.error) {
            [[[UIAlertView alloc] initWithTitle:@"保存に失敗しました" message:exportSession.error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        VideoPostPreparation.postData.cheer_flag = self.checkbox.isChecked;
        VideoPostPreparation.postData.memo = self.textView.text;
        
        [VideoPostPreparation initiateUploadTaskChain:exportSession.outputUrl];
        
        [Permission showThePopupForPushNoticationsOnce:self after:^{
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        }];
    }];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    if ([text isEqualToString:@"\n"]) {
        VideoPostPreparation.postData.memo = textView.text;
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


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
    [self.textView resignFirstResponder];
}




- (void)cancelSaveToCameraRoll
{
    [_exportSession cancelExport];
}

- (IBAction)cancelTapped:(id)sender {
    [self cancelSaveToCameraRoll];
}


#pragma mark - 戻る
- (IBAction)popViewController1:(UIStoryboardSegue *)segue {
    
    NSLog(@"%s",__func__);
    
}



- (IBAction)restnameInsert:(id)sender {
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)
    {
        [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[requestGPSPopupViewController new]];
    }
    else if ([Network offline]) {
        [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[RestAddPopupViewController new]];
    }
    else {
        [self showPopupWithTransitionStyle:STPopupTransitionStyleSlideVertical rootViewController:[RestPopupViewController new]];
    }
    
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
