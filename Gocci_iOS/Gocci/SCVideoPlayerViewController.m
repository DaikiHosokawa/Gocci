//
//   SCVideoPlayerViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import "SCVideoPlayerViewController.h"
#import "SCAssetExportSession.h"

@interface SCVideoPlayerViewController () {
    SCPlayer *_player;
}

@end

@implementation SCVideoPlayerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        // Custom initialization
    }
	
    return self;
}

- (void)dealloc {
    self.filterSwitcherView = nil;
    [_player pause];
    _player = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//ナビゲーションバーに画像
	{
		//タイトル画像設定
		CGFloat height_image = self.navigationController.navigationBar.frame.size.height;
		CGFloat width_image = height_image;
		UIImage *image = [UIImage imageNamed:@"naviIcon.png"];
		UIImageView *navigationTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width_image, height_image)];
		navigationTitle.image = image;
		self.navigationItem.titleView =navigationTitle;
	}

    
    self.filterSwitcherView.refreshAutomaticallyWhenScrolling = NO;
    self.filterSwitcherView.contentMode =  UIViewContentModeScaleAspectFill;
    
    self.filterSwitcherView.filterGroups = @[
                                             [NSNull null],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectNoir"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectChrome"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTonal"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectFade"]],
                                             // Adding a filter created using CoreImageShop
                                             //[SCFilterGroup filterGroupWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"a_filter" withExtension:@"cisf"]]
                                             ];
    
    //3.5inch
    CGRect rect3 = [UIScreen mainScreen].bounds;
    if (rect3.size.height == 480) {
        
        // UIImageViewの初期化
        CGRect rect = CGRectMake(200, 360, 128, 128);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        // 画像の読み込み
        imageView.image = [UIImage imageNamed:@"2x_Swipe_Right-1.png"];
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView];
        
        // UIImageViewの初期化
        CGRect rect2 = CGRectMake(10, 360, 128, 128);
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:rect2];
        // 画像の読み込み
        imageView2.image = [UIImage imageNamed:@"2x_Swipe_Left.png"];
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView2];
       
    }
    
    //4.7inch対応
    CGRect rect4 = [UIScreen mainScreen].bounds;
    if (rect4.size.height == 667) {
        
        // UIImageViewの初期化
        CGRect rect = CGRectMake(240, 560, 140, 140);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        // 画像の読み込み
        imageView.image = [UIImage imageNamed:@"2x_Swipe_Right-1.png"];
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView];
        
        // UIImageViewの初期化
        CGRect rect2 = CGRectMake(10, 560, 140, 140);
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:rect2];
        // 画像の読み込み
        imageView2.image = [UIImage imageNamed:@"2x_Swipe_Left.png"];
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView2];
        
    }
    
    //5.5inch対応
    CGRect rect5 = [UIScreen mainScreen].bounds;
    if (rect5.size.height == 736) {
        // UIImageViewの初期化
        CGRect rect = CGRectMake(265, 590, 150, 150);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
        // 画像の読み込み
        imageView.image = [UIImage imageNamed:@"2x_Swipe_Right-1.png"];
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView];
        
        // UIImageViewの初期化
        CGRect rect2 = CGRectMake(10, 590, 150, 150);
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:rect2];
        // 画像の読み込み
        imageView2.image = [UIImage imageNamed:@"2x_Swipe_Left.png"];
        // UIImageViewのインスタンスをビューに追加
        [self.view addSubview:imageView2];
    }
    
    //4inch
    CGRect rect6 = [UIScreen mainScreen].bounds;
    if (rect6.size.height == 568) {

    // UIImageViewの初期化
    CGRect rect = CGRectMake(200, 460, 128, 128);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    // 画像の読み込み
    imageView.image = [UIImage imageNamed:@"2x_Swipe_Right-1.png"];
    // UIImageViewのインスタンスをビューに追加
    [self.view addSubview:imageView];
    
    // UIImageViewの初期化
    CGRect rect2 = CGRectMake(10, 460, 128, 128);
    UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:rect2];
    // 画像の読み込み
    imageView2.image = [UIImage imageNamed:@"2x_Swipe_Left.png"];
    // UIImageViewのインスタンスをビューに追加
    [self.view addSubview:imageView2];
    }
	
	// !!!:dezamisystem
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完了"
																			  style:UIBarButtonItemStyleBordered
																			 target:self
																			 action:@selector(saveToCameraRoll)];
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
	_player = [SCPlayer player];
    _player.CIImageRenderer = self.filterSwitcherView;
    
	_player.loopEnabled = YES;
#endif
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// !!!:dezamisystem
	[self.navigationController setNavigationBarHidden:NO animated:NO]; // ナビゲーションバー表示
	
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
	[_player setItemByAsset:_recordSession.assetRepresentingRecordSegments];
	[_player play];
#endif

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
    if ([self isFirstRun]) {
        //Calling this methods builds the intro and adds it to the screen. See below.
        [self showDefaultContentView];
    }
}

- (BOOL)isFirstRun
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"firstRunDate7"]) {
        // 日時が設定済みなら初回起動でない
        return NO;
    }
    // 初回起動日時を設定
    [userDefaults setObject:[NSDate date] forKey:@"firstRunDate7"];
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
        descriptionLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:18.];
        descriptionLabel.text = @"好きなエフェクトをかけてオシャレにしましょう";
        [_firstContentView addSubview:descriptionLabel];
        
        [_firstContentView setDismissHandler:^(DemoContentView *view) {
            // to dismiss current cardView. Also you could call the `dismiss` method.
            [CXCardView dismissCurrent];
        }];
    }
    
    [CXCardView showWithView:_firstContentView draggable:YES];
}


//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    [_player setItemByAsset:_recordSession.assetRepresentingRecordSegments];
//	[_player play];
//}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [_player pause];
#endif
}

- (void)saveToCameraRoll
{
	// !!!:dezamisystem
#if (!TARGET_IPHONE_SIMULATOR)
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    SCFilterGroup *currentFilter = self.filterSwitcherView.selectedFilterGroup;
    
    void(^completionHandler)(NSError *error) = ^(NSError *error) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (error == nil) {
            [self.recordSession saveToCameraRoll];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"保存失敗しました！撮り直してください" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    };
    
    if (currentFilter == nil) {
        [self.recordSession mergeRecordSegments:completionHandler];
    } else {
        SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:self.recordSession.assetRepresentingRecordSegments];
        exportSession.filterGroup = currentFilter;
        exportSession.sessionPreset = SCAssetExportSessionPresetHighestQuality;
        exportSession.outputUrl = self.recordSession.outputUrl;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.keepVideoSize = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            completionHandler(exportSession.error);
        }];
    }
#endif
    [self performSegueWithIdentifier:@"gotoSubmit" sender:self];
    
}

#pragma mark - 
- (IBAction)buttonFadeInOut:(id)sender
{
	
}

@end
