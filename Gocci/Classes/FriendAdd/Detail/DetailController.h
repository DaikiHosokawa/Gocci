//
//  DetailController.h
//  Gocci
//
//  Created by Castela on 2015/10/08.
//  Copyright © 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailController;

@protocol DetailControllerDelegate <NSObject>

@end

@interface DetailController : UIViewController

@property(nonatomic,strong) id<DetailControllerDelegate> delegate;


@end
