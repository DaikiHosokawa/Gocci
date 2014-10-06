//
//  submitViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/15.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
@protocol submitViewControllerDelegate;


@interface submitViewController : UIViewController<UITextViewDelegate,UIScrollViewDelegate>

{
    
IBOutlet UIButton *_twitterBtn;
IBOutlet UIButton *_facebookBtn;
__weak IBOutlet UITextView *textView;
}

- (IBAction)pushComplete:(id)sender;


@end
