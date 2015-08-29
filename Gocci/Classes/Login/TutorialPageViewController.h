//
//  TutorialPageViewController.h
//  Gocci
//
//  Created by Castela on 2015/08/28.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageViewController : UIViewController <UIPageViewControllerDataSource,UIWebViewDelegate,UIPageViewControllerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

//page3
@property(weak,nonatomic) UITextField *usernameField;
@property(weak,nonatomic) UIView *popupView;
@property(weak,nonatomic) UIWebView *popupWebView;
@property(weak,nonatomic) UIButton *popupCancel;
@property(weak,nonatomic) UILabel *popuptitle;

@end
