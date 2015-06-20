//
//  beforeRecorderTableViewController.h
//  Gocci
//
//  Created by デザミ on 2015/02/06.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXCardView.h"
#import "DemoContentView.h"
#import "LocationClient.h"

@interface beforeRecorderTableViewController : UITableViewController<UIAlertViewDelegate>{
    UIAlertView *FirstalertView;
    CGFloat lat;
    CGFloat lon;
}

@property (weak, nonatomic) IBOutlet UIView *emptyView;

@end
