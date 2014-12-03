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
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStyleBordered target:self action:@selector(saveToCameraRoll)];
    
	_player = [SCPlayer player];
    _player.CIImageRenderer = self.filterSwitcherView;
    
	_player.loopEnabled = YES;
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_player setItemByAsset:_recordSession.assetRepresentingRecordSegments];
	[_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}


- (void)saveToCameraRoll {
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
    [self performSegueWithIdentifier:@"gotoSubmit" sender:self];
    
}

@end
