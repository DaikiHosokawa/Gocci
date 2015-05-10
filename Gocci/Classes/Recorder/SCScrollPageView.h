//
//  SCScrollPageView.h
//  Gocci
//
//  Created by デザミ on 2015/05/10.
//  Copyright (c) 2015年 Massara. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCFirstView;
@class SCSecondView;

@interface SCScrollPageView : UIView<UIScrollViewDelegate>

-(void)showInView:(UIView*)superview first:(SCFirstView*)viewfirst second:(SCSecondView*)viewsecond;

@end
