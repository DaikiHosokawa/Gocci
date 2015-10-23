//
//  VRViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import "SCFirstView.h"
#import "SCSecondView.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "EditVideoController.h"


@interface SCRecorderViewController : UIViewController<EditVideoDelegate,SCRecorderDelegate, SCFirstViewDelegate,EditVideoDelegate,UIAlertViewDelegate,NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate,UIImagePickerControllerDelegate>{
    UIAlertView *FirstalertView;
    UIAlertView *SecondalertView;
}


#pragma mark - beforeRecorderViewController


-(void)execSubmit;
-(void)onRetake;
-(void)cancelSubmit;
-(void)updatePieChartWith:(double)now MAX:(double)max;
- (void)recorderSubmitPopupViewOnTwitterShare;
- (void)recorderSubmitPopupViewOnFacebookShare:(UIViewController *)viewcontroller;

@end
