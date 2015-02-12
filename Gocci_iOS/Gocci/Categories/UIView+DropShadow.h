//
//  UIView+DropShadow.h
//  Gocci
//

#import <UIKit/UIKit.h>

@interface UIView (DropShadow)

/**
 *  View に影を設定
 */
- (void)dropShadow;

/**
 *  View に影を設定
 *  (弱め)
 */
- (void)dropShadowLight;

@end
