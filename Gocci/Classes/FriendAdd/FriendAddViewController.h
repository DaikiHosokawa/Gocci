//
//  TimelinePageMenuViewController.h
//  Gocci
//
//  Created by INASE on 2015/06/18.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AddressController.h"
#import "FacebookController.h"
#import "TwitterController.h"
#import "DetailController.h"

@interface FriendAddViewController : UIViewController<AddressControllerDelegate,FacebookControllerDelegate, TwitterControllerDelegate,DetailControllerDelegate>

@property id supervc;

@end
