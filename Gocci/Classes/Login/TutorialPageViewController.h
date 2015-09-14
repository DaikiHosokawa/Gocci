//
//  TutorialPageViewController.h
//  Gocci
//
//  Created by Castela on 2015/08/28.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FHSTwitterEngine.h"

@interface TutorialPageViewController : UIViewController <FHSTwitterEngineAccessTokenDelegate,UIPageViewControllerDataSource,UIWebViewDelegate,UIPageViewControllerDelegate,UIScrollViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

//page3
@property(weak,nonatomic) UITextField *username;
@property(weak,nonatomic) UIView *popupView;
@property(weak,nonatomic) UIWebView *popupWebView;
@property(weak,nonatomic) UIButton *popupCancel;
@property(weak,nonatomic) UILabel *popuptitle;

@property(weak,nonatomic) UIButton *registerButton;

@end
