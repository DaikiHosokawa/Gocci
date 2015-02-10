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
    self.layer.shadowOffset = CGSizeMake(2.0, 0.0);
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOpacity = 0.2;
}

@end
