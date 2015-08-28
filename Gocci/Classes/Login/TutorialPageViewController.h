//
//  TutorialPageViewController.h
//  Gocci
//
//  Created by Castela on 2015/08/28.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property(weak,nonatomic) UITextField *usernameField;

@end
