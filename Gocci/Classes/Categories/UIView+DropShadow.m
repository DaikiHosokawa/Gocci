//
//  UIView+DropShadow.m
//  Gocci
//

#import "UIView+DropShadow.h"

@import QuartzCore;

@implementation UIView (DropShadow)

- (void)dropShadow
{
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOpacity = 0.2;
}

- (void)dropShadowLight
{
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOpacity = 0.2;
}

@end
