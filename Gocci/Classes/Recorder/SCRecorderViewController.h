//
//  VRViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import "CXCardView.h"
#import "DemoContentView.h"
#import "SCFirstView.h"
#import "SCSecondView.h"
#import <FBSDKShareKit/FBSDKShareKit.h>


@interface SCRecorderViewController : UIViewController<SCRecorderDelegate, SCFirstViewDelegate,SCSecondViewDelegate,UIAlertViewDelegate,NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>{
    UIAlertView *FirstalertView;
    UIAlertView *SecondalertView;
}


#pragma mark - beforeRecorderViewController
-(void)sendTenmeiString:(NSString*)str;
-(void)sendKakakuValue:(int)value;
-(void)sendHitokotoValue:(NSString *)value;




-(void)execSubmit;
-(void)cancelSubmit;
-(void)updatePieChartWith:(double)now MAX:(double)max;
- (void)recorderSubmitPopupViewOnTwitterShare;
- (void)recorderSubmitPopupViewOnFacebookShare:(UIViewController *)viewcontroller;

@end
