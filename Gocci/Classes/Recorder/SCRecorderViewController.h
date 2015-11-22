//
//  VRViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa.
//  Copyright (c) 2014年 INASE,inc. All rights reserved.
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



@end
