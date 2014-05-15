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


@interface submitViewController : UIViewController
{
IBOutlet UIButton *_twitterBtn;
IBOutlet UIButton *_facebookBtn;
}

- (IBAction)postTwitter:(id)sender;
- (IBAction)postFacebook:(id)sender;
@end
