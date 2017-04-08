//
//  TwitterController.h
//  Gocci
//
//  Created by Castela on 2015/10/08.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TwitterController;

@protocol TwitterControllerDelegate <NSObject>

@end

@interface TwitterController : UITableViewController

@property(nonatomic,strong) id<TwitterControllerDelegate> delegate;


@end
