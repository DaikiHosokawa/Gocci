//
//   SCImageViewDisPlayViewController.h
//  Gocci
//
//  Created by Daiki Hosokawa on 2014/05/10.
//  Copyright (c) 2014年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSwipeableFilterView.h"

@interface SCImageDisplayerViewController : UIViewController

@property (nonatomic, strong) UIImage *photo;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;

@end
