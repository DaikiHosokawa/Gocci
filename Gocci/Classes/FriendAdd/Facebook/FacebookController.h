//
//  FacebookController.h
//  Gocci
//
//  Created by Castela on 2015/10/08.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FacebookController;

@protocol FacebookControllerDelegate <NSObject>

@end

@interface FacebookController : UITableViewController

@property(nonatomic,strong) id<FacebookControllerDelegate> delegate;


@end
