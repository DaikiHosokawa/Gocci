//
//   SCImageViewDisPlayViewController.m
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//


#import "SCImageDisplayerViewController.h"

@interface SCImageDisplayerViewController () 

@end

@implementation SCImageDisplayerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	// !!!:dezamisystem
//	self.navigationController.navigationBarHidden = NO;
	
    self.filterSwitcherView.preferredCIImageTransform = [CIImageRendererUtils preferredCIImageTransformFromUIImage:self.photo];
    
    self.filterSwitcherView.CIImage = [CIImage imageWithCGImage:self.photo.CGImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
	// !!!:dezamisystem
//	self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.filterSwitcherView setNeedsDisplay];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// !!!:dezamisystem
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(saveToCameraRoll)];
	
    self.filterSwitcherView.contentMode = UIViewContentModeScaleAspectFit;
    /*
    self.filterSwitcherView.filterGroups = @[
                                             [NSNull null],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectNoir"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectChrome"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTonal"]],
                                             [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectFade"]]
                                             ];
*/
	// Do any additional setup after loading the view.
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Done!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed :(" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}

- (void)saveToCameraRoll {
    UIImage *image = [self.filterSwitcherView currentlyDisplayedImageWithScale:self.photo.scale orientation:self.photo.imageOrientation];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

@end
