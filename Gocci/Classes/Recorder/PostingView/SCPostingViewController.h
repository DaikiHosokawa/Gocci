//
//  SCPostingViewController.h
//  Gocci
//
//  Created by INASE on 2015/05/08.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCSecondView.h"
#import "SCRecorderViewController.h"

//@class SCPostingViewController;


typedef void (^SCPostingViewControllerCancelCallback)(void);

@interface SCPostingViewController : UIViewController<SCSecondViewDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,SCRecorderDelegate>
{
    UIAlertView *FirstalertView;
    UIAlertView *SecondalertView;
    SCRecorderViewController *SCRecorder;
}

-(void)afterRecording :(UIViewController *)viewController;


@end
