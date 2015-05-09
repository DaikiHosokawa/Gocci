//
//  SCPostingViewController.h
//  Gocci
//
//  Created by デザミ on 2015/05/08.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCSecondView.h"

//@class SCPostingViewController;


typedef void (^SCPostingViewControllerCancelCallback)(void);

@interface SCPostingViewController : UIViewController<SCSecondViewDelegate,UITableViewDelegate,UITableViewDataSource>

@end
