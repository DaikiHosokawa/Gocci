//
//  UIImage+BlurEffect.h
//  LeiblancMogl
//
//  Created by Gio Viet on 12/27/14.
//  Copyright (c) 2014 FIS.TES.RD.N3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BlurEffect)
{
}

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

+ (UIImage *)takeSnapshotOfView:(UIView *)view;

@end
